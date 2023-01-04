/*
 *   @Class: AddressSearchController
 *   @TestClass: AddressSearchControllerTest
*/
global class AddressSearchControllerMock implements HttpCalloutMock {

    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response.
        // Set response values, and 
        // return response.
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{\"predictions\":[{\"description\":\"ViaRoma,Torino,TO,Italia\",\"matched_substrings\":[{\"length\":8,\"offset\":0}],\"place_id\":\"EhxWaWEgUm9tYSwgVG9yaW5vLCBUTywgSXRhbGlhIi4qLAoUChIJBdZSXW5tiEcR6j6U21UbHDUSFAoSCSW-GGQSbYhHEb93nNYD-AOJ\",\"reference\":\"EhxWaWEgUm9tYSwgVG9yaW5vLCBUTywgSXRhbGlhIi4qLAoUChIJBdZSXW5tiEcR6j6U21UbHDUSFAoSCSW-GGQSbYhHEb93nNYD-AOJ\",\"structured_formatting\":{\"main_text\":\"ViaRoma\",\"main_text_matched_substrings\":[{\"length\":8,\"offset\":0}],\"secondary_text\":\"Torino,TO,Italia\"},\"terms\":[{\"offset\":0,\"value\":\"ViaRoma\"},{\"offset\":10,\"value\":\"Torino\"},{\"offset\":18,\"value\":\"TO\"},{\"offset\":22,\"value\":\"Italia\"}],\"types\":[\"route\",\"geocode\"]}],\"status\":\"OK\"}');
        if (req.getEndpoint().contains('details')) {
            res.setBody('Test Response');
        }
        res.setStatusCode(200);
        return res;
    }
    
}