//
//  APIService.swift
//  NewsAPIReader
//
//  Created by Игровой Kirirushi on 15/06/2020.
//  Copyright © 2020 Kirirushi. All rights reserved.
//

import Alamofire
import AlamofireObjectMapper
import RxSwift
import ObjectMapper

class APIService {
  typealias Result = Swift.Result
  
  static let shared = APIService()
  
  private var apiKey: String {
    Bundle.main.object(forInfoDictionaryKey: "NewsAPIKey") as? String ?? ""
  }
  
  private init() {}
  
  private func request<T: Mappable>(method: Alamofire.HTTPMethod,
                            url: String,
                            parameters: Parameters,
                            type: T.Type) -> Observable<Result<T, APIError>> {
    return Observable.create { observer in
      Alamofire
        .request(url, method: method, parameters: parameters,
                 encoding: URLEncoding.default, headers: nil)
        .responseObject { (response: DataResponse<T>) in
          switch response.result {
          case .success(let object):
            observer.onNext(.success(object))
          case .failure:
            observer.onNext(.failure(.serverError(message: "Ошибка подключения")))
          }
        }
      return Disposables.create {}
    }
  }
}
extension APIService {
  func loadNews(q: String, page: Int) -> Observable<Result<EverythingModel, APIError>> {
    let parameters: Parameters = ["apikey": apiKey,
                                  "language": "ru",
                                  "sortBy": "publishedAt",
                                  "q": q,
                                  "page": page]
    return request(method: .get, url: URLs.fullUrl.appending(URLs.everything), parameters: parameters, type: EverythingModel.self)
      .map { result -> Result<EverythingModel, APIError> in
        if case let .success(success) = result, let errorMessage = success.message {
          return .failure(.serverError(message: errorMessage))
        }
        return result
      }
  }
  
  func loadTopHeadlines(page: Int) -> Observable<Result<EverythingModel, APIError>> {
    let parameters: Parameters = ["apikey": apiKey,
                                  "country": "ru",
                                  "page": page]
    return request(method: .get, url: URLs.fullUrl.appending(URLs.topHeadlines), parameters: parameters, type: EverythingModel.self)
      .map { result -> Result<EverythingModel, APIError> in
        if case let .success(success) = result, let errorMessage = success.message {
          return .failure(.serverError(message: errorMessage))
        }
        return result
      }
  }
}

struct URLs {
  static let baseUrl = "https://newsapi.org"
  static let apiVersion = "/v2"
  
  static let everything = "/everything"
  static let topHeadlines = "/top-headlines"
  
  static var fullUrl: String { baseUrl + apiVersion }
}

enum APIError: Error {
  case noInternet
  case serverError(message: String)
}
