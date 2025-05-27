import zipfile
import os

# Define project structure and content
project_name = "movieproductionsystem"
base_dir = f"/mnt/data/{project_name}"
src_main_java = os.path.join(base_dir, "src/main/java/com/project/movieproductionsystem")
src_main_resources = os.path.join(base_dir, "src/main/resources")
src_test_java = os.path.join(base_dir, "src/test/java/com/project/movieproductionsystem")

# Create directories
os.makedirs(src_main_java, exist_ok=True)
os.makedirs(src_main_resources, exist_ok=True)
os.makedirs(src_test_java, exist_ok=True)

# Create basic files

# pom.xml content with Spring Boot 3.2.5
pom_content = '''<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
	<modelVersion>4.0.0</modelVersion>
	<parent>
		<groupId>org.springframework.boot</groupId>
		<artifactId>spring-boot-starter-parent</artifactId>
		<version>3.2.5</version>
		<relativePath/>
	</parent>
	<groupId>com.project</groupId>
	<artifactId>movieproductionsystem</artifactId>
	<version>0.0.1-SNAPSHOT</version>
	<name>movieproductionsystem</name>
	<description>Spring Boot project for movie production system</description>
	<properties>
		<java.version>21</java.version>
	</properties>
	<dependencies>
		<dependency>
			<groupId>org.springframework.boot</groupId>
			<artifactId>spring-boot-starter-web</artifactId>
		</dependency>
		<dependency>
			<groupId>org.springframework.boot</groupId>
			<artifactId>spring-boot-starter-data-jpa</artifactId>
		</dependency>
		<dependency>
			<groupId>org.springframework.boot</groupId>
			<artifactId>spring-boot-starter-validation</artifactId>
		</dependency>
		<dependency>
			<groupId>org.springframework.boot</groupId>
			<artifactId>spring-boot-devtools</artifactId>
			<scope>runtime</scope>
			<optional>true</optional>
		</dependency>
		<dependency>
			<groupId>org.springframework.boot</groupId>
			<artifactId>spring-boot-starter-test</artifactId>
			<scope>test</scope>
		</dependency>
		<dependency>
			<groupId>org.projectlombok</groupId>
			<artifactId>lombok</artifactId>
			<scope>provided</scope>
		</dependency>
		<dependency>
			<groupId>mysql</groupId>
			<artifactId>mysql-connector-java</artifactId>
			<version>8.0.32</version>
		</dependency>
		<dependency>
			<groupId>org.modelmapper</groupId>
			<artifactId>modelmapper</artifactId>
			<version>3.2.0</version>
		</dependency>
	</dependencies>
	<build>
		<plugins>
			<plugin>
				<groupId>org.springframework.boot</groupId>
				<artifactId>spring-boot-maven-plugin</artifactId>
			</plugin>
		</plugins>
	</build>
</project>
'''
with open(os.path.join(base_dir, "pom.xml"), "w") as f:
    f.write(pom_content)

# Basic Application class
main_app = '''package com.project.movieproductionsystem;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class MovieProductionSystemApplication {
    public static void main(String[] args) {
        SpringApplication.run(MovieProductionSystemApplication.class, args);
    }
}
'''
with open(os.path.join(src_main_java, "MovieProductionSystemApplication.java"), "w") as f:
    f.write(main_app)

# application.properties
with open(os.path.join(src_main_resources, "application.properties"), "w") as f:
    f.write("# Add your configuration here\n")

# Create ZIP file
zip_path = f"/mnt/data/{project_name}.zip"
with zipfile.ZipFile(zip_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
    for root, dirs, files in os.walk(base_dir):
        for file in files:
            filepath = os.path.join(root, file)
            zipf.write(filepath, os.path.relpath(filepath, base_dir))

zip_path
