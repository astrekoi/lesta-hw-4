pipeline {
    agent any

    tools {
        maven 'maven-3.8.1'
        jdk 'jdk16'
        nodejs 'node-16'
    }

    stages {
        stage('Build & Test backend') {
            steps {
                dir("backend") {
                    sh 'mvn package'
                }
            }

            post {
                success {
                    junit 'backend/target/surefire-reports/**/*.xml'
                }
            }
        }
        
        stage('Save artifacts') {
            steps {
                archiveArtifacts(artifacts: 'backend/target/sausage-store-0.0.1-SNAPSHOT.jar')
            }
        }
    }
}