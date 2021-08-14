
import Foundation

protocol CoinManagerDelegate {
    func didFailWithError(error: Error)
    func retrieveData(coin: CoinModel)
}

struct CoinManager {
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate"
    let apiKey = "4E049B5C-263A-4B45-89FD-D1B012D14684"
    
    var delegate: CoinManagerDelegate?
    
    let currencyArray = ["BTC", "ETH", "BNB", "XRP", "DOGE", "ADA", "DOT", "UNI", "BCH"]

    func getCoinPrice(for currency:String){
        let coinURL = "\(baseURL)/\(currency)/USD?apikey=\(apiKey)"
        performRequest(urlString: coinURL)
    }
    
    func performRequest(urlString: String){
        if let url = URL(string: urlString){
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) {(data, response, error) in
                if error != nil{
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data{
                    if let retrievedData = self.parseJSON(safeData){
                        self.delegate?.retrieveData(coin: retrievedData)
                    }
                }
                
            }
            task.resume()
        }
        
    }
    func parseJSON(_ coinData: Data) -> CoinModel?{
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(CoinData.self, from: coinData)
            let rate = decodedData.rate
            return CoinModel(rate: rate)
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
