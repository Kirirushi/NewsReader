//
//  CoreDataService.swift
//  NewsAPIReader
//
//  Created by Игровой Kirirushi on 17/06/2020.
//  Copyright © 2020 Kirirushi. All rights reserved.
//

import CoreData
import RxSwift

class CoreDataService {
  static let shared = CoreDataService()
  private(set) var articles: [Article] = []
  private(set) var favorites: [Article] = []
  private(set) var all: [Article] = []
  
  let favoriteChanged = PublishSubject<(Article, Bool)>()
  
  private let disposeBag = DisposeBag()
  
  private init() {
    topRecentObservable
      .subscribe(onNext: { [weak self] articles in
        self?.articles = articles
      })
      .disposed(by: disposeBag)
    
    favoritesObservable
      .subscribe(onNext: { [weak self] articles in
        self?.favorites = articles
      })
      .disposed(by: disposeBag)
    
    allObservable
      .subscribe(onNext: { [weak self] articles in
        self?.all = articles
      })
    .disposed(by: disposeBag)
  }
  
  let topRecentObservable: CoreDataObservable<Article> = {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }
    let managedContext = appDelegate.persistentContainer.viewContext
    let fetchRequest: NSFetchRequest<Article> = Article.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "articleType = %@", ArticleType.topRecent.rawValue)
    let sortByDate = NSSortDescriptor(key: #keyPath(Article.publishedAt), ascending: false)
    fetchRequest.sortDescriptors = [sortByDate]
    
    return CoreDataObservable(fetchRequest: fetchRequest, context: managedContext)
  }()
  
  let favoritesObservable: CoreDataObservable<Article> = {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }
    let managedContext = appDelegate.persistentContainer.viewContext
    let fetchRequest: NSFetchRequest<Article> = Article.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "favorite = %@", NSNumber(value: true))
    let sortByDate = NSSortDescriptor(key: #keyPath(Article.publishedAt), ascending: false)
    fetchRequest.sortDescriptors = [sortByDate]
    
    return CoreDataObservable(fetchRequest: fetchRequest, context: managedContext)
  } ()
  
  let allObservable: CoreDataObservable<Article> = {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }
    let managedContext = appDelegate.persistentContainer.viewContext
    let fetchRequest: NSFetchRequest<Article> = Article.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "articleType = %@", ArticleType.all.rawValue)
    let sortByDate = NSSortDescriptor(key: #keyPath(Article.publishedAt), ascending: false)
    fetchRequest.sortDescriptors = [sortByDate]
    
    return CoreDataObservable(fetchRequest: fetchRequest, context: managedContext)
  }()
  
  func saveTopRecent(with models: [NewsModel]) {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
    let managedContext = appDelegate.persistentContainer.viewContext
    let entity = NSEntityDescription.entity(forEntityName: "Article",
                                            in: managedContext)!
    models.forEach { model in
      guard !articles.map({ $0.title }).contains(model.title) else { return }
      
      let article = Article(entity: entity, insertInto: managedContext)
      article.author = model.author
      article.content = model.content
      article.articleDescription = model.description
      article.title = model.title
      
      if let publishedAt = model.publishedAt {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        article.publishedAt = dateFormatter.date(from: publishedAt)
      }
      if let url = model.url {
        article.url = URL(string: url)
      }
      if let url = model.urlToImage {
        article.urlToImage = URL(string: url)
      }
      
      article.favorite = false
      
      article.articleType = ArticleType.topRecent.rawValue
    }
    
    do {
      try managedContext.save()
    } catch let error as NSError {
      print("Could not save. \(error), \(error.userInfo)")
    }
  }
  
  func saveAll(with models: [NewsModel]) {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
    let managedContext = appDelegate.persistentContainer.viewContext
    let entity = NSEntityDescription.entity(forEntityName: "Article",
                                            in: managedContext)!
    models.forEach { model in
      guard !all.map({ $0.title }).contains(model.title) else { return }
      
      let article = Article(entity: entity, insertInto: managedContext)
      article.author = model.author
      article.content = model.content
      article.articleDescription = model.description
      article.title = model.title
      
      if let publishedAt = model.publishedAt {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        article.publishedAt = dateFormatter.date(from: publishedAt)
      }
      if let url = model.url {
        article.url = URL(string: url)
      }
      if let url = model.urlToImage {
        article.urlToImage = URL(string: url)
      }
      
      article.favorite = false
      
      article.articleType = ArticleType.all.rawValue
    }
    do {
      try managedContext.save()
    } catch let error as NSError {
      print("Could not save. \(error), \(error.userInfo)")
    }
  }
  
  func updateFavorite(title: String, favorite: Bool) {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
    let managedContext = appDelegate.persistentContainer.viewContext
    let fetchRequest: NSFetchRequest<Article> = Article.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "title = %@", title)
    fetchRequest.fetchLimit = 1
    do {
      let results = try managedContext.fetch(fetchRequest)
      if let favoriteChanging = results.first {
        favoriteChanging.favorite = favorite
        do {
          try managedContext.save()
          favoriteChanged.onNext((favoriteChanging, favorite))
        } catch {
          print("Save error: \(error.localizedDescription)")
        }
      }
    } catch {
      print("Fetch error: \(error.localizedDescription)")
    }
  }
}
