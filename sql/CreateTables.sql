# Create the trips table

CREATE TABLE trips (
	id varchar(36),
	timestamp numeric(14,3),
	hour integer,
	day integer,
	month integer,
	datetime datetime,
	timezone varchar(16),
	source varchar(23),
	destination varchar(23),
	cab_type varchar(4),
	product_id varchar(36),
	name varchar(12),
	price numeric(5,2),
	distance numeric(4,2),
	surge_multiplier numeric(4,2),
	primary key(id)
);

# Create the weather table

CREATE TABLE weather (
	weather_record_number int AUTO_INCREMENT NOT NULL,
	id varchar(36),
	temperature numeric(5,2),
	precipIntensity numeric(6,4),
	precipProbability numeric(4,2),
	humidity numeric(4,2),
	windSpeed numeric(5,2),
	temperatureHigh numeric(5,2),
	temperatureHighTime integer,
	temperatureLow numeric(5,2),
	temperatureLowTime integer,
	sunriseTime integer,
	sunsetTime integer,
	primary key(weather_record_number),
	FOREIGN KEY (id) REFERENCES trips (id)
);

# Create the locaiton table

CREATE TABLE location (
	record_number int AUTO_INCREMENT NOT NULL,
	id varchar(36),
	longitude numeric(8,4),
	latitude numeric(7,4),
	primary key(record_number),
	FOREIGN KEY (id) REFERENCES trips (id)
);