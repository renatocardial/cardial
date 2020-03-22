import XCTest
import Cardial

class Tests: XCTestCase {
    
    lazy var marvelAPI: MarvelAPI = {
        return MarvelAPI()
    }()
    
    override func setUp() {
        super.setUp()
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRequest() {
        let expectation = self.expectation(description: "requesting")
        NetworkProvider.setDebug(debug: true)
        NetworkProvider.request(api: marvelAPI, path: MarvelPath.characters.rawValue, model: Hero.self) { (response) in
            
            self.validateResultCharacters(response: response)
            
            expectation.fulfill()
        }
        
         waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testRequestMock() {
        
        let endpoint = Endpoint(
            api: marvelAPI,
            method: .GET ,
            path: MarvelPath.characters.rawValue,
            mockInTest: true
        )
        
        let expectation = self.expectation(description: "requesting")
        
        NetworkProvider.endpointRequest(endpoint: endpoint, model: Hero.self) { (response) in
        
            self.validateResultCharacters(response: response)
            if let hero = (response.model as? [Hero])?.first {
                XCTAssertEqual(hero.name, "3-D Man Mocked")
            }
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
        
    }
    
}

extension Tests {
    
    private func validateResultCharacters(response: NetworkProvider.ResponseCallback) {
        XCTAssertTrue(response.success, "Result wasn't have success")
        XCTAssertNotNil(response.model, "Model result shouldn't to be nil")
        XCTAssertNil(response.error, "Error result should to be nil")
        
        guard let heros = response.model as? [Hero] else {
            XCTFail("Result mode should to be an array of the Heros")
            printAny(response)
            return
        }
        
        XCTAssertGreaterThan(heros.count, 0)
    }
    
}
