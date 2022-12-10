import UIKit

// MARK: - MusicData
struct MusicData: Codable {
    let resultCount: Int
    let results: [Music]
}

// MARK: - Music
struct Music: Codable {
    let songName: String?
    let artistName: String?
    let albumName: String?
    let previewUrl: String?
    let imageUrl: String?
    private let releaseDate: String?
    
    // 네트워크에서 주는 이름을 변환하는 방법 (원시값)
    // (서버: trackName ===> songName)
    enum CodingKeys: String, CodingKey {
        case songName = "trackName"
        case artistName
        case albumName = "collectionName"
        case previewUrl
        case imageUrl = "artworkUrl100"
        case releaseDate
    }
    
}

enum ArtistName: String, Codable {
    case frankOcean = "Frank Ocean"
}


func getMethod(completionHandler: @escaping ([Music]?) -> Void) {
    
    // URL구조체 만들기
    guard let url = URL(string: "https://itunes.apple.com/search?term=frank+ocean&media=music") else {
        print("Error: cannot create URL")
        completionHandler(nil)
        return
    }
    
    // URL요청 생성
    var request = URLRequest(url: url)
    request.httpMethod = "GET"

    
    URLSession.shared.dataTask(with: request) { data, response, error in
        // 에러가 없어야 넘어감
        guard error == nil else {
            print("Error: error calling GET")
            print(error!)
            completionHandler(nil)
            return
        }
        // 옵셔널 바인딩
        guard let safeData = data else {
            print("Error: Did not receive data")
            completionHandler(nil)
            return
        }
        // HTTP 200번대 정상코드인 경우만 다음 코드로 넘어감 - 생략 가능
        guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
            print("Error: HTTP request failed")
            completionHandler(nil)
            return
        }
        
        do {
            let decoder = JSONDecoder()
            let musicData = try decoder.decode(MusicData.self, from: safeData)
            completionHandler(musicData.results)
            return
        } catch {
            completionHandler(nil)
            return
        }


    }.resume()     // 시작
}

getMethod { musicArray in
    
    guard let array = musicArray else { return }
    dump(array)
    
}

