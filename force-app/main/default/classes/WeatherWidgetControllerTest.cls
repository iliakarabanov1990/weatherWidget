
@isTest
private class WeatherWidgetControllerTest {

    @testSetup
    public static void setup() {

        List<User> testUsers = new List<User>();

        Profile stProfile = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        testUsers.add(new User(Alias = 'standt', Email='oWUser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = stProfile.Id, City = 'Borisov',
            TimeZoneSidKey='America/Los_Angeles', UserName='oWUser@testorg.com'));

        testUsers.add(new User(Alias = 'standt', Email='oW2User@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = stProfile.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='oW2User@testorg.com'));      

        insert testUsers;    
    }

    @isTest
    public static void testGetingCityOfUSer() {

        User testUser = [SELECT Id FROM USER WHERE LastName='Testing'];
        String city;

        Test.startTest();
          
        System.runAs(testUser) {
            city = WeatherWidgetController.getCity();
        }
   
        Test.stopTest();
        
        System.assertEquals('Borisov', city, 'Wrong city from user');
    }

    @isTest
    public static void testGetingDefaultCity() {

        User testUser = [SELECT Id FROM USER WHERE LastName='Testing2'];
        String city;

        Test.startTest();
          
        System.runAs(testUser) {
            city = WeatherWidgetController.getCity();
        }
   
        Test.stopTest();
        
        System.assertEquals('Minsk', city, 'Wrong default city');
    }

    @isTest
    public static void testWeatherData() {
   
        User testUser = [SELECT Id FROM USER WHERE LastName='Testing'];
        Map<String, Object> result;

        SingleRequestMock fakeGEOResp = new SingleRequestMock(200,
        'Complete',
        '[{"name": "Minsk", "local_names": {"mk": "Минск"}, "lat": 53.9024716, "lon": 27.5618225, "country": "BY"}]',
        null);

        SingleRequestMock fakeCurrWeatherResp = new SingleRequestMock(200,
        'Complete',
        '[{"Test": "Test"}]',
        null);

        SingleRequestMock fakeWeatherForecastResp = new SingleRequestMock(200,
        'Complete',
        '[{"Test": "Test"}]',
        null);

        Map<String, HttpCalloutMock> endpointsTestResp = new Map<String, HttpCalloutMock>();

        endpointsTestResp.put('https://api.openweathermap.org/geo/1.0/direct?q=Minsk&appid=b3be926049e1925509ae4154c16b808e', fakeGEOResp);
        //endpointsTestResp.put('https://api.openweathermap.org/geo/1.0/direct?q=Borisov&appid=b3be926049e1925509ae4154c16b808e', fakeGEOResp);    
        endpointsTestResp.put('https://api.openweathermap.org/data/2.5/weather?lat=53.9024716&lon=27.5618225&appid=b3be926049e1925509ae4154c16b808e&units=metric', fakeCurrWeatherResp);
        //endpointsTestResp.put('https://api.openweathermap.org/data/2.5/weather?lat=54.2240665&lon=28.5117849&appid=b3be926049e1925509ae4154c16b808e&units=metric', fakeCurrWeatherResp);
        endpointsTestResp.put('https://api.openweathermap.org/data/2.5/forecast?lat=53.9024716&lon=27.5618225&appid=b3be926049e1925509ae4154c16b808e&units=metric', fakeWeatherForecastResp);
        //endpointsTestResp.put('https://api.openweathermap.org/data/2.5/forecast?lat=54.2240665&lon=28.511784&appid=b3be926049e1925509ae4154c16b808e&units=metric', fakeWeatherForecastResp);

        HttpCalloutMock multiCalloutMock = new MultiRequestMock(endpointsTestResp);

        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        System.runAs(testUser) {
            Test.startTest();
            result = WeatherWidgetController.getWeatherData('Minsk');
            Test.stopTest();
        }

        System.assertEquals(2, result.size(), 'Wrong answer from openweathermap');
    }

    @isTest
    public static void testWeatherDataForEmptyCity() {
   
        Test.startTest();
        Map<String, Object> result = WeatherWidgetController.getWeatherData('  ');
        Test.stopTest();
        
        System.assertEquals(0, result.size(), 'Wrong answer from openweathermap');
    }

    @isTest
    public static void testWeatherDataGEOError() {
   
        User testUser = [SELECT Id FROM USER WHERE LastName='Testing'];
        Map<String, Object> result;

        SingleRequestMock fakeGEOResp = new SingleRequestMock(418,
        'I\'m a teapot',
        '[]',
        null);

        Map<String, HttpCalloutMock> endpointsTestResp = new Map<String, HttpCalloutMock>();

        endpointsTestResp.put('https://api.openweathermap.org/geo/1.0/direct?q=Minsk&appid=b3be926049e1925509ae4154c16b808e', fakeGEOResp);

        HttpCalloutMock multiCalloutMock = new MultiRequestMock(endpointsTestResp);

        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        System.runAs(testUser) {
            Test.startTest();
            result = WeatherWidgetController.getWeatherData('Minsk');
            Test.stopTest();
        }

        System.assertEquals('information about the city was not found, check the entered city', result.get('error'), 'Wrong processing GEO error from openweathermap');
    }

    @isTest
    public static void testWeatherDataGEOEEmpty() {
   
        User testUser = [SELECT Id FROM USER WHERE LastName='Testing'];
        Map<String, Object> result;

        SingleRequestMock fakeGEOResp = new SingleRequestMock(200,
        'Complete',
        '[]',
        null);

        Map<String, HttpCalloutMock> endpointsTestResp = new Map<String, HttpCalloutMock>();

        endpointsTestResp.put('https://api.openweathermap.org/geo/1.0/direct?q=sdfgasdrfdscv&appid=b3be926049e1925509ae4154c16b808e', fakeGEOResp);

        HttpCalloutMock multiCalloutMock = new MultiRequestMock(endpointsTestResp);

        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        System.runAs(testUser) {
            Test.startTest();
            result = WeatherWidgetController.getWeatherData('sdfgasdrfdscv');
            Test.stopTest();
        }

        System.assertEquals('information about the city was not found, check the entered city', result.get('error'), 'Wrong processing GEO error from openweathermap');
    }

    @isTest
    public static void testWeatherDataCurrWeatherError() {
   
        User testUser = [SELECT Id FROM USER WHERE LastName='Testing'];
        Map<String, Object> result;

        SingleRequestMock fakeGEOResp = new SingleRequestMock(200,
        'Complete',
        '[{"name": "Minsk", "local_names": {"mk": "Минск"}, "lat": 53.9024716, "lon": 27.5618225, "country": "BY"}]',
        null);

        SingleRequestMock fakeCurrWeatherResp = new SingleRequestMock(418,
        'I\'m a teapot',
        '[]',
        null);

        Map<String, HttpCalloutMock> endpointsTestResp = new Map<String, HttpCalloutMock>();

        endpointsTestResp.put('https://api.openweathermap.org/geo/1.0/direct?q=Minsk&appid=b3be926049e1925509ae4154c16b808e', fakeGEOResp);  
        endpointsTestResp.put('https://api.openweathermap.org/data/2.5/weather?lat=53.9024716&lon=27.5618225&appid=b3be926049e1925509ae4154c16b808e&units=metric', fakeCurrWeatherResp);

        HttpCalloutMock multiCalloutMock = new MultiRequestMock(endpointsTestResp);

        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        System.runAs(testUser) {
            Test.startTest();
            result = WeatherWidgetController.getWeatherData('Minsk');
            Test.stopTest();
        }

        System.assertEquals('information about current weather was not found, check the entered city', result.get('error'), 'Wrong processing curr weather error from openweathermap');
    }

    @isTest
    public static void testWeatherDataWeatherForecastError() {
   
        User testUser = [SELECT Id FROM USER WHERE LastName='Testing'];
        Map<String, Object> result;

        SingleRequestMock fakeGEOResp = new SingleRequestMock(200,
        'Complete',
        '[{"name": "Minsk", "local_names": {"mk": "Минск"}, "lat": 53.9024716, "lon": 27.5618225, "country": "BY"}]',
        null);

        SingleRequestMock fakeCurrWeatherResp = new SingleRequestMock(200,
        'Complete',
        '[{"Test": "Test"}]',
        null);

        SingleRequestMock fakeWeatherForecastResp = new SingleRequestMock(418,
        'I\'m a teapot',
        '[]',
        null);

        Map<String, HttpCalloutMock> endpointsTestResp = new Map<String, HttpCalloutMock>();

        endpointsTestResp.put('https://api.openweathermap.org/geo/1.0/direct?q=Minsk&appid=b3be926049e1925509ae4154c16b808e', fakeGEOResp);   
        endpointsTestResp.put('https://api.openweathermap.org/data/2.5/weather?lat=53.9024716&lon=27.5618225&appid=b3be926049e1925509ae4154c16b808e&units=metric', fakeCurrWeatherResp);
        endpointsTestResp.put('https://api.openweathermap.org/data/2.5/forecast?lat=53.9024716&lon=27.5618225&appid=b3be926049e1925509ae4154c16b808e&units=metric', fakeWeatherForecastResp);

        HttpCalloutMock multiCalloutMock = new MultiRequestMock(endpointsTestResp);

        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        System.runAs(testUser) {
            Test.startTest();
            result = WeatherWidgetController.getWeatherData('Minsk');
            Test.stopTest();
        }

        System.assertEquals('information about weather forecast was not found, check the entered city', result.get('error'), 'Wrong processing forecast error from openweathermap');
    }

}