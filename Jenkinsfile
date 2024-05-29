pipeline {
    agent any
    parameters {
        choice choices: ["Baseline", "APIS", "Full"],
                description: 'Type of scan that is going to perform inside the container',
                name: 'SCAN_TYPE'
                
        choice choices: ["r_html", "r_html_full", "r_md", "r_xml", "r_xml_full", "r_json", "r_json_full"],
                description: 'Types of report',
                name: 'REPORT_TYPE'
        
        string defaultValue: "https://juice-shop.herokuapp.com",
                description: 'Target URL to scan',
                name: 'TARGET'
                
        string defaultValue: "16777216",
                description: 'Request Body length',
                name: 'REQUEST_BODY_LENGTH'

        string defaultValue: "2000",
                description: 'Response Body length',
                name: 'RESPONSE_BODY_LENGTH'        

        string defaultValue: "juice_shop",
                description: 'Product name in Defect Dojo',
                name: 'PRODUCT_NAME_DD'
                
        password defaultValue: "token_DD",
                description: 'The personal access token used to access the API',
                name: 'TOKEN_DD'

        string defaultValue: "/api/v2/import-scan/",
                description: "The DefectDojo import-scan endpoint. Default: /api/v2/import-scan/",
                name: 'DD_ENDPOINT'
    }
    stages {
        stage('Build and Setup ZAP Docker Image') {
            steps {
                script {
                    echo "Pulling up last ZAP container --> Start"
                    sh """
                        cd ${PWD}/workspace/DAST_ZAP/zap_scan &&
                        docker build --tag zap --progress=plain .
                        """
                    echo "Building up last VMS container --> End"
                    
                }
            }
        }

        stage('ZAP Scan') {
            steps {
                script {
                    try {
                        scan_type = "${params.SCAN_TYPE}"
                        report_type = "${params.REPORT_TYPE}"
                        body_req = "${params.REQUEST_BODY_LENGTH}"
                        body_res = "${params.RESPONSE_BODY_LENGTH}"
                        target = "${params.TARGET}"
                        product_name_dd = "${params.PRODUCT_NAME_DD}"
                        
                        if (scan_type == "Baseline") {
                        sh """
                        docker run --memory=125g -e JAVA_OPTS="-XX:+UseContainerSupport -XX:InitialRAMPercentage=50.0 -XX:MaxRAMPercentage=95.0 -XX:+AlwaysPreTouch" --cpus=6.4 --user zap -v ${WORKSPACE}/zap_scan/zap_reports:/zap/wrk/:rw -t zap \
                        zap-baseline-custom.py \
                        -t $target \
                        --$report_type=$product_name_dd-\$(date "+%d-%m-%Y-%H-%M-%S") \
                        -a \
                        -z "-config database.request.bodysize=$body_req -config database.response.bodysize=$body_res auth.exclude_url=https://juice-shop.herokuapp.com/#/login*"
                        """
                    } else if (scan_type == "APIS") {
                        sh """
                        docker run --memory=125g -e JAVA_OPTS="-XX:+UseContainerSupport -XX:InitialRAMPercentage=50.0 -XX:MaxRAMPercentage=95.0 -XX:+AlwaysPreTouch" --cpus=6.4 --user zap -v ${WORKSPACE}/zap_scan/zap_reports:/zap/wrk/:rw -t zap \
                        zap-api-scan-custom.py \
                        -t $target \
                        --$report_type=$product_name_dd-\$(date "+%d-%m-%Y-%H-%M-%S") \
                        """
                    } else if (scan_type == "Full") {
                        sh """
                        docker run --memory=125g -e JAVA_OPTS="-XX:+UseContainerSupport -XX:InitialRAMPercentage=50.0 -XX:MaxRAMPercentage=95.0 -XX:+AlwaysPreTouch" --cpus=6.4 --user zap -v ${WORKSPACE}/zap_scan/zap_reports:/zap/wrk/:rw -t zap \
                        zap-full-scan-custom.py \
                        -t $target \
                        --$report_type=$product_name_dd-\$(date "+%d-%m-%Y-%H-%M-%S") \
                        -z "-Xmx120g -config database.request.bodysize=$body_req -config database.response.bodysize=$body_res"
                        """
                    } else {
                        echo "Something went wrong..."
                    }
                    }
                    catch (err) {
                        echo err.getMessage()
                        
                    }
                }
            }
        }
        
        stage('Upload report to DefectDojo') {
            steps {
                script {
                    token_DD = "${params.TOKEN_DD}"
                    script {
                    def reportFileName = sh (script: "ls ${WORKSPACE}/zap_scan/zap_reports | grep -E '$product_name_dd-[0-9]{2}-[0-9]{2}-[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{2}.xml' | sort | tail -1", 
                        returnStdout: true
                        ).trim()
                    echo "Report: $reportFileName"
                    sh """
                    cd ${WORKSPACE}/zap_scan/zap_reports
                    curl -o - -X POST -location 'http://localhost:8081/api/v2/import-scan/' \
                    -H 'Authorization:Token $token_DD' \
                    -H 'Content-Type: multipart/form-data' \
                    -H 'accept: application/json' \
                    -F "scan_type=ZAP Scan" \
                    -F "product_name = juice_shop" \
                    -F "engagement_name = juice_shop" \
                    -F "auto_create_context=True" \
                    -F "file=@$reportFileName"
                    """
                    }
                }
            }
        }
        
    }
}
