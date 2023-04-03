@Grab(group='org.apache.httpcomponents', module='httpclient', version='4.5.3')

import org.apache.http.HttpEntity
import org.apache.http.client.methods.HttpPost
import org.apache.http.entity.StringEntity
import org.apache.http.impl.client.CloseableHttpClient
import org.apache.http.impl.client.HttpClients

def sendLogToSplunk(String log, String host, String token) {
    def url = "https://<SPLUNK_SERVER>/services/collector/event"
    def client = HttpClients.createDefault()
    def post = new HttpPost(url)
    post.addHeader("Authorization", "Splunk " + token)
    post.addHeader("Content-Type", "application/json")
    def payload = [
        "host": host,
        "event": log
    ]
    def body = new StringEntity(JsonOutput.toJson(payload))
    post.setEntity(body)
    def response = client.execute(post)
    def entity = response.getEntity()
    if (entity != null) {
        entity.consumeContent()
    }
    client.close()
}

// Example usage
sendLogToSplunk("Error occurred on line 42", "myserver.example.com", "<SPLUNK_TOKEN>")
