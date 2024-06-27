@isTest
public class MultiRequestMock implements HttpCalloutMock {

    public class MultiRequestMockException extends Exception {

    }

    Map<String, HttpCalloutMock> requests;

    public MultiRequestMock(Map<String, HttpCalloutMock> requests) {
        this.requests = requests;
    }

    public HTTPResponse respond(HTTPRequest req) {
	HttpCalloutMock mock = requests.get(req.getEndpoint());
	    if (mock != null) {
	        return mock.respond(req);
            } 
        else {
     		throw new MultiRequestMockException('HTTP callout not supported for test methods: ' +  req);
	    }
    }

    public void addRequestMock(String url, HttpCalloutMock mock) {
        requests.put(url, mock);
    }
}