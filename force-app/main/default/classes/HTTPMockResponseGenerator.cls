/*
    * @author RANAND
    * @date 04/09/2020
    * @group Case Closed
    * @description Mock Response generator class
 
 */
@isTest(isParallel=true)
public class HTTPMockResponseGenerator implements HttpCalloutMock{
    protected Integer code;
    protected String status;
    protected String body;

    public HTTPMockResponseGenerator(Integer code, String status, String body) {
        this.code = code;
        this.status=status;
        this.body = body;
    }
    public HttpResponse respond(HttpRequest req){
        HttpResponse res = new HttpResponse();
        res.setStatusCode(this.code);
        res.setBody(this.body);
        return res;
    }
}
