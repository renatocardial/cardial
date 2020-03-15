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
        
        NetworkProvider.request(api: marvelAPI, path: MarvelPath.characters.rawValue, model: Hero.self) { (result) in
            
            XCTAssertTrue(result.success, "Result wasn't have success")
            XCTAssertNotNil(result.model, "Model result shouldn't to be nil")
            XCTAssertNil(result.error, "Error result should to be nil")
            
            guard let heros = result.model as? [Hero] else {
                XCTFail("Result mode should to be an array of the Heros")
                printAny(result)
                return
            }
            
            XCTAssertGreaterThan(heros.count, 0)
            
            expectation.fulfill()
        }
        
         waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
