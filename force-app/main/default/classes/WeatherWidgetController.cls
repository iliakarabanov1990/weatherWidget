public with sharing class WeatherWidgetController {

    @AuraEnabled(cacheable=true)
    public static String getCity(){

        User userData = [SELECT City FROM User WHERE Id = :UserInfo.getUserId()];

        if(!String.isBlank(userData.City)){
            return userData.City;
        }

        WeatherData__mdt weatherData = WeatherData__mdt.getInstance('defaultCity');
        return weatherData.City__c;
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getWeatherData(String city){

        Map<String, Object> result = new Map<String, Object>();

        if(String.isBlank(city)){
            return result;
        }

        HttpResponse response;
        String responseBody;
        
        String appId = 'b3be926049e1925509ae4154c16b808e';
        //Http http = new Http();  

        response = sendRequest('https://api.openweathermap.org/geo/1.0/direct?q=' + city + '&appid=' + appId);
        
        if (response.getStatusCode() == 200) {
            responseBody = response.getBody();
        } else {
            result.put('error', 'information about the city was not found, check the entered city');
            return result;
        }

         if(responseBody == '[]'){
            result.put('error', 'information about the city was not found, check the entered city');
            return result;
        }

        List<GeoJSON2Apex> coordinatesList = (List<GeoJSON2Apex>) JSON.deserialize(responseBody, List<GeoJSON2Apex>.class);

        GeoJSON2Apex coordinates = coordinatesList[0];

        response = sendRequest('https://api.openweathermap.org/data/2.5/weather?lat=' + coordinates.lat + '&lon=' + coordinates.lon + '&appid=' + appId + '&units=metric');
        if (response.getStatusCode() != 200) {
            result.put('error', 'information about current weather was not found, check the entered city');
            return result;
        }

        result.put('currWeather', response.getBody());

        response = sendRequest('https://api.openweathermap.org/data/2.5/forecast?lat=' + coordinates.lat + '&lon=' + coordinates.lon + '&appid=' + appId + '&units=metric');

        if (response.getStatusCode() != 200) {
            result.put('error', 'information about weather forecast was not found, check the entered city');
            return result;
        }

        result.put('weatherForecast', response.getBody());

        return result; 
    }

    private static HttpResponse sendRequest(String endpoint){
       
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setEndpoint(endpoint);

        return http.send(request);           
    }
    
}