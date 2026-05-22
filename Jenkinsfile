pipeline {
    agent any

    environment {
        // Nombre de la imagen de Docker
        IMAGE_NAME = 'mi-app-python'
        // Host de preproducción (según tu requerimiento)
        SSH_HOST = '172.16.10.200'
        SSH_USER = 'iscenidet'
        
        // --- SEGURIDAD ---
        // Debes crear una credencial en Jenkins de tipo "Username with password"
        // ID de la credencial: 'preproduccion-ssh-cred'
        // Username: iscenidet
        // Password: ISDcc*2023+cenidet
        SSH_CREDENTIAL_ID = 'preproduccion-ssh-cred'
    }

    stages {
        stage('Build Docker Image') {
            steps {
                script {
                    echo "Construyendo la imagen de Docker..."
                    // Construye la imagen basada en el Dockerfile local
                    sh "docker build -t ${IMAGE_NAME}:${env.BUILD_ID} ."
                }
            }
        }

        stage('Deploy to Pre-Production') {
            steps {
                echo "Desplegando en preproducción: ${SSH_USER}@${SSH_HOST}..."
                
                withCredentials([usernamePassword(credentialsId: SSH_CREDENTIAL_ID, passwordVariable: 'SSH_PASSWORD', usernameVariable: 'SSH_USERNAME')]) {
                    script {
                        // Aquí guardamos la imagen en un archivo .tar, la enviamos por SSH y la cargamos en el servidor destino.
                        // NOTA: Esto requiere que el servidor Jenkins tenga instalado 'sshpass'.
                        // Una alternativa más robusta es usar el plugin 'SSH Pipeline Steps' o 'Publish over SSH'.
                        
                        sh """
                        # Guardar imagen en archivo tar
                        docker save ${IMAGE_NAME}:${env.BUILD_ID} -o ${IMAGE_NAME}.tar
                        
                        # Usar sshpass para autenticación con contraseña y transferir el archivo
                        export SSHPASS=\$SSH_PASSWORD
                        sshpass -e scp -o StrictHostKeyChecking=no ${IMAGE_NAME}.tar ${SSH_USERNAME}@${SSH_HOST}:/tmp/
                        
                        # Conectarse por SSH, cargar la imagen, detener el contenedor anterior y ejecutar el nuevo
                        sshpass -e ssh -o StrictHostKeyChecking=no ${SSH_USERNAME}@${SSH_HOST} '
                            docker load -i /tmp/${IMAGE_NAME}.tar &&
                            docker stop mi-app-contenedor || true &&
                            docker rm mi-app-contenedor || true &&
                            docker run -d --name mi-app-contenedor -p 9091:9091 ${IMAGE_NAME}:${env.BUILD_ID}
                        '
                        """
                    }
                }
            }
        }
    }
    
    post {
        always {
            // Limpiar el espacio de trabajo de Jenkins después de la ejecución
            cleanWs()
            // Limpiar la imagen local del nodo de Jenkins para no llenar el disco
            sh "docker rmi ${IMAGE_NAME}:${env.BUILD_ID} || true"
        }
    }
}
