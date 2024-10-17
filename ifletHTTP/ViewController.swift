//
//  ViewController.swift
//  ifletHTTP
//
//  Created by 황석현 on 10/16/24.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var movieTableView: UITableView!
    var movies: [Movie]? = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        movieTableView.dataSource = self
        movieTableView.delegate = self
        movieTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        fetchMovies()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let movie = movies?[indexPath.row]
        cell.textLabel?.text = movie?.title
        return cell
    }
    
    func fetchMovies() {
        if let apiKey = Bundle.main.object(forInfoDictionaryKey: "TMDB_API_KEY") as? String {
            print("API KEY:\(apiKey)")
            let urlString = "https://api.themoviedb.org/3/movie/popular?api_key=\(apiKey)&language=ko-KR&page=1"
            // 나머지 코드 진행
            guard let url = URL(string: urlString) else {
                print("Invalid URL")
                return
            }
            
            
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("Status Code: \(httpResponse.statusCode)")
                }
                
                guard let data = data else {
                    print("No data received")
                    return
                }
                
                do {
                    // JSON 파싱 후 results를 movies 배열에 저장
                    let decoder = JSONDecoder()
                    let movieResponse = try decoder.decode(MovieResponse.self, from: data)
                    self.movies = movieResponse.results
                    
                    // UI 업데이트는 메인 스레드에서
                    DispatchQueue.main.async {
                        self.movieTableView.reloadData() // 테이블 뷰를 리로드하여 화면 갱신
                    }
                    
                } catch let jsonError {
                    print("Failed to decode JSON: \(jsonError.localizedDescription)")
                }
            }
            task.resume()
        }
        }
        

//        let apiKey = "16004ede4c2584a8931df5e64bd60408"
//        let urlString = "https://api.themoviedb.org/3/movie/popular?api_key=\(apiKey)&language=ko-KR&page=1"
       
    
}

struct MovieResponse: Codable {
    let page: Int
    let results: [Movie]
    let total_pages: Int
    let total_results: Int
}

struct Movie: Codable {
    let title: String
    let release_date: String
    let overview: String
    let vote_average: Double
}
