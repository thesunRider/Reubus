 # Reubus

Reubus is simply an ML driven Crime Data analyser, Packed with powerful tools for post and pre crime data analysis.
 
## Getting Started 

There are 4 main core functionalities of Reubus 
which is backed by ML

- Node editor
- Map predictor
- Webscraper
- FIR filter



 See deployment for notes on how to deploy

### Prerequisites 

Runs on windows only. Needs:

- Python3
- Internet Explorer 11.0

### Installing

Launch the main.au3 file to build from source in Scite or reubus.exe to execute the compiled binary

## Running the tests 

goto [http://localhost:8843](http://localhost:8843)
to check wether the node editor is working.

Open IE and load the maptest.html to rum a check on wether ActiveX is enabled.

### Adding Packages

 Reubus is written in such a way that it can be extended and programmed ,ie more features can be added to it by the user itself.For adding packages make sure the ```package.ini``` is supplied with your GUI application,the application will be embedded inside Reubus while running and can get and transfer data with Reubus

 ``` 
[package]
name=Reubus extension
type=python
 ``` 

If the application to be embedded is in python make sure that POPUP windows style is used for the GUI,for autoit sourcecodes this is not needed.


## Deployment

 Before Launching the app run ``` server_start.bat``` and make sure that ActiveX is enabled ,and Script permissions are given in Internet Explorer

## Built With

* [Autoit](http://www.dropwizard.io/1.0.2/docs/) - Front end GUI
* [Python](https://maven.apache.org/) - Backend ML and server handling
* [Javascript](https://rometools.github.io/rome/) - Communicate with server end and Autoit

 ## Authors 

* **Arjun**
* **Govind** 
* **Surya**
* **Sandra**
* **Leos**

See list of contributers: [contributors](https://github.com/HacKP-CyberDome/reubus-app/network/dependencies) who participated in this project.

 ## License

 This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

 ## Acknowledgments 


* Hat tip to anyone whose code was used * Inspiration * etc 
