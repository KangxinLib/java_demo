package com.weijilab.demo;

import java.util.TreeMap;

import org.springframework.stereotype.Controller;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.http.MediaType;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

@SpringBootApplication
@Controller
public class DemoApplication {

    public static void main(String[] args) {
        SpringApplication.run(DemoApplication.class, args);
    }

    @GetMapping("/")
    public String index() {
        return "index";
    }

    @GetMapping("/greeting")
    public String index(@RequestParam(name="name", required=false, defaultValue="World") String name, Model model) {
        model.addAttribute("name", name);
        return "greeting";
    }

    /**
     * @return system environment variables, formatted as an ASCII table
     */
    @GetMapping(value = "/basic-info", produces = MediaType.TEXT_PLAIN_VALUE)
    public String getBasicInfo() {
        String result = "";
        result = result + "ENVIRONMENT this is a test thanks\n";
        result = result + "-----------\n";
        for (var e : new TreeMap<>(System.getenv()).entrySet()) {
            // key length 30 so that KUBERNETES_SERVICE_PORT_HTTPS fits in
            // value length 42 so that the overall table fits in an 80 char terminal window
            result = result + String.format("| %-30s | %-42s |\n", stripAndTruncate(30, e.getKey()), stripAndTruncate(42, e.getValue()));
        }
        return result;
    }

    private String stripAndTruncate(int length, String s) {
        return truncate(length, stripNewlinesAndTabs(s));
    }

    private String stripNewlinesAndTabs(String s) {
        if (s == null) {
            return s;
        }
        return s.replaceAll("\\s+", " ");
    }

    private String truncate(int length, String s) {
        if (s != null && s.length() > length) {
            return s.substring(0, length - 3) + "...";
        }
        return s;
    }
}
