//
//  ViewController.swift
//  MusicApp
//
//  Created by kaki on 2022/12/10.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var musicTableView: UITableView!
    
//    // ๐ ์์น ์ปจํธ๋กค๋ฌ ์์ฑ ===> ๋ค๋น๊ฒ์ด์ ์์ดํ์ ํ ๋น
//    let searchController = UISearchController()
    
    // ๐ ์์น Results์ปจํธ๋กค๋ฌ โญ๏ธ
    let searchController = UISearchController(searchResultsController: UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SearchResultViewController") as! SearchResultViewController)
    
    // ๋คํธ์ํฌ ๋งค๋์  (์ฑ๊ธํค)
    var networkManager = NetworkManager.shared
    
    // (์์ ๋ฐ์ดํฐ๋ฅผ ๋ค๋ฃจ๊ธฐ ์ํจ) ๋น๋ฐฐ์ด๋ก ์์
    var musicArrays: [Music] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupDatas()
        setupSearchBar()
    }
    
    // ์์น๋ฐ ์ธํ
    func setupSearchBar() {
        self.title = "Music Search"
        navigationItem.searchController = searchController
//        // ๐ 1) (๋จ์)์์น๋ฐ์ ์ฌ์ฉ
//        searchController.searchBar.delegate = self
        
        // ๐ 2) ์์น(๊ฒฐ๊ณผ)์ปจํธ๋กค๋ฌ์ ์ฌ์ฉ (๋ณต์กํ ๊ตฌํ ๊ฐ๋ฅ)
        //     ==> ๊ธ์๋ง๋ค ๊ฒ์ ๊ธฐ๋ฅ + ์๋ก์ด ํ๋ฉด์ ๋ณด์ฌ์ฃผ๋ ๊ฒ๋ ๊ฐ๋ฅ
        searchController.searchResultsUpdater = self
        
        // ์ฒซ๊ธ์ ๋๋ฌธ์ ์ค์  ์์ ๊ธฐ
        searchController.searchBar.autocapitalizationType = .none
    }
    
    // ํ์ด๋ธ๋ทฐ ์ธํ
    func setupTableView() {
        musicTableView.dataSource = self
        musicTableView.delegate = self
        
        // Nib ํ์ผ์ ์ฌ์ฉํ๋ค๋ฉด ๋ฑ๋ก์ ๊ณผ์ ์ด ํ์
        musicTableView.register(UINib(nibName: Cell.musicCellIdentifier, bundle: nil), forCellReuseIdentifier: Cell.musicCellIdentifier)
    }
    
    // ๋ฐ์ดํฐ ์์
    func setupDatas() {
        // ๋คํธ์ํน์ ์์
        networkManager.fetchMusic(searchTerm: "frankocean") { result in
            switch result {
            case .success(let musicDatas):
                // ๋ฐ์ดํฐ(๋ฐฐ์ด)์ ๋ฐ์์ค๊ณ  ๋ ํ
                self.musicArrays = musicDatas
                // ํ์ด๋ธ๋ทฐ ๋ฆฌ๋ก๋ (๋ฐ๋์ ๋ฉ์ธํ์์ ์งํํ  ๊ฒ)
                DispatchQueue.main.async {
                    self.musicTableView.reloadData()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.musicArrays.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = musicTableView.dequeueReusableCell(withIdentifier: Cell.musicCellIdentifier, for: indexPath) as! MusicCell
        
        cell.imageUrl = musicArrays[indexPath.row].imageUrl
        
        cell.songNameLaber.text = musicArrays[indexPath.row].songName
        cell.artistNameLabel.text = musicArrays[indexPath.row].artistName
        cell.albumNameLabel.text = musicArrays[indexPath.row].albumName
        cell.releaseDateLabel.text = musicArrays[indexPath.row].releaseDateString
        
        cell.selectionStyle = .none
        return cell        
    }
    
    
}

extension ViewController: UITableViewDelegate {
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 120
//    }
    
    // ํ์ด๋ธ๋ทฐ ์์ ๋์ด๋ฅผ ์ ๋์ ์ผ๋ก ์กฐ์ ํ๊ณ  ์ถ๋ค๋ฉด ๊ตฌํํ  ์ ์๋ ๋ฉ์๋
    // ์ ๋ฉ์๋ ๋์ ์ ์ฌ์ฉ ๊ฐ๋ฅ
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}

//MARK: - ๐ (๋จ์) ์์น๋ฐ ํ์ฅ
//extension ViewController: UISearchBarDelegate {
//
//    // ์ ํ 1) ์ ์ ๊ฐ ๊ธ์๋ฅผ ์๋ ฅํ๋ ์๊ฐ๋ง๋ค ํธ์ถ๋๋ ๋ฉ์๋
////    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
////        // ๋ค์ ๋น ๋ฐฐ์ด๋ก ๋ง๋ค๊ธฐ
////        self.musicArrays = []
////
////        // ๋คํธ์ํน ์์
////        networkManager.fetchMusic(searchTerm: searchText) { result in
////            switch result {
////            case .success(let musicDatas):
////                self.musicArrays = musicDatas
////                DispatchQueue.main.async {
////                    self.musicTableView.reloadData()
////                }
////            case .failure(let error):
////                print(error.localizedDescription)
////            }
////        }
////    }
//
//    // ์ ํ 2) ๊ฒ์(Search) ๋ฒํผ์ ๋๋ ์๋ ํธ์ถ๋๋ ๋ฉ์๋
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        guard let text = searchController.searchBar.text else { return }
//        // ๋ค์ ๋น ๋ฐฐ์ด๋ก ๋ง๋ค๊ธฐ
//        self.musicArrays = []
//        // ๋คํธ์ํน ์์
//        networkManager.fetchMusic(searchTerm: text) { result in
//            switch result {
//            case .success(let musicDatas):
//                self.musicArrays = musicDatas
//                DispatchQueue.main.async {
//                    self.musicTableView.reloadData()
//                }
//            case .failure(let error):
//                print(error.localizedDescription)
//            }
//        }
//        self.view.endEditing(true)
//    }
//}

//MARK: -  ๐ ๊ฒ์ํ๋ ๋์ (์๋ก์ด ํ๋ฉด์ ๋ณด์ฌ์ฃผ๋) ๋ณต์กํ ๋ด์ฉ ๊ตฌํ ๊ฐ๋ฅ
extension ViewController: UISearchResultsUpdating {
    // ์ ์ ๊ฐ ๊ธ์๋ฅผ ์๋ ฅํ๋ ์๊ฐ๋ง๋ค ํธ์ถ๋๋ ๋ฉ์๋ ==> ์ผ๋ฐ์ ์ผ๋ก ๋ค๋ฅธ ํ๋ฉด์ ๋ณด์ฌ์ค๋ ๊ตฌํ
    func updateSearchResults(for searchController: UISearchController) {
        print("์์น๋ฐ์ ์๋ ฅ๋๋ ๋จ์ด", searchController.searchBar.text ?? "")
        // ๊ธ์๋ฅผ ์น๋ ์๊ฐ์ ๋ค๋ฅธ ํ๋ฉด์ ๋ณด์ฌ์ฃผ๊ณ  ์ถ๋ค๋ฉด (์ปฌ๋ ์๋ทฐ๋ฅผ ๋ณด์ฌ์ค)
        let vc = searchController.searchResultsController as! SearchResultViewController
        // ์ปฌ๋ ์๋ทฐ์ ์ฐพ์ผ๋ ค๋ ๋จ์ด ์ ๋ฌ
        vc.searchTerm = searchController.searchBar.text ?? ""
    }
}
