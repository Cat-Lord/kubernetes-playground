package sk.catheaven.http_liveness;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class HttpLivenessProbeTestApplication {

	public static void main(String[] args) {
		try {
			Thread.sleep(5000);
			SpringApplication.run(HttpLivenessProbeTestApplication.class, args);
		} catch (InterruptedException exception) {
			System.err.println("Interrupt exception caught");
		}
	}

}
