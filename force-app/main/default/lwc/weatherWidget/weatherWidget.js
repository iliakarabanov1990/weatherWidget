import { LightningElement, wire } from 'lwc';
import WEATHER_ICONS from '@salesforce/resourceUrl/WeatherIcons';
import getWeatherData from '@salesforce/apex/WeatherWidgetController.getWeatherData'; 
import getDefaultCity from '@salesforce/apex/WeatherWidgetController.getCity';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class WeatherWidget extends LightningElement {
   
    city = '';
    mainIcon = '';
    temperature = 0;
    feelsLike = 0;
    windSpeed = 0;
    forecastData = [];
    whetherDescription = '';

    @wire(getWeatherData, { city: '$city'})
    getData({ error, data }) {
        if (data) {
            if (data.error){
                this.cleanShowedData();
                this.showToast('Error', data.error, 'error');             
            }
            else if(data.currWeather){
                let weatherData = JSON.parse(data.currWeather);
                this.mainIcon = WEATHER_ICONS + `/icons/${weatherData.weather[0].icon}.png`;   
                this.temperature = Math.round(weatherData.main.temp); 
                this.feelsLike = Math.round(weatherData.main.feels_like);
                this.windSpeed = Math.round(weatherData.wind.speed);
                this.whetherDescription = weatherData.weather[0].main;

                this.showWeatherForecast(JSON.parse(data.weatherForecast));
            }  
            else{
                this.cleanShowedData();
            }        
        } else if (error) {
            this.showToast('Error', error.body.message, 'error');       
        }
    }

    connectedCallback(){
        getDefaultCity().then(city => this.city = city);       
    }

    showWeatherForecast(resp){
        this.forecastData = resp.list.
          filter(el => el.dt_txt.includes("12:00:00"))
          .map(day => {
              return {date: new Date(day.dt * 1000).toLocaleDateString('en-GB', { day: 'numeric', month: 'short' }),
              icon: `${WEATHER_ICONS}/icons/${day.weather[0].icon}.png`,
              temp: Math.round(day.main.temp),
              wind: Math.round(day.wind.speed)};
          });
    }

    cleanShowedData(){
        this.city = '';
        this.mainIcon = '';
        this.temperature = 0;
        this.feelsLike = 0;
        this.windSpeed = 0;
        this.forecastData = [];
        this.whetherDescription = '';
    }

    // Function to show toast notifications
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    handleCityChange(evt){
        this.city = evt.target.value.trim();
    } 
}