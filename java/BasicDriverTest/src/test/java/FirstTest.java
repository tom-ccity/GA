package cineworld;

import net.lightbody.bmp.core.har.HarEntry;
import org.openqa.selenium.By;
import org.openqa.selenium.Proxy;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.firefox.FirefoxOptions;
import org.openqa.selenium.firefox.FirefoxDriver;

import java.util.List;
import java.util.concurrent.TimeUnit;

import net.lightbody.bmp.BrowserMobProxyServer;
import net.lightbody.bmp.client.ClientUtil;
import net.lightbody.bmp.core.har.Har;

import org.testng.Assert;
import org.testng.annotations.AfterClass;
import org.testng.annotations.BeforeClass;
import org.testng.annotations.Test;

public class FirstTest {

    private static WebDriver driver;
    private static BrowserMobProxyServer server;
    public static final String PageURL="https://www.cineworld.co.uk/";
    public static final String PosterXPath="//div[@class='tab-pane collapsed active']//div[@aria-expanded='true']/div[@class='poster-container']";

    @BeforeClass // Runs this method before the first test method in the current class is invoked
    public void setUp() {
        server = new BrowserMobProxyServer();
        server.start();
        Proxy proxy = ClientUtil.createSeleniumProxy(server);
        FirefoxOptions desiredFirefoxOptions = new FirefoxOptions();
        desiredFirefoxOptions.setProxy(proxy);
        driver = new FirefoxDriver(desiredFirefoxOptions);
        driver.manage().timeouts().implicitlyWait(25, TimeUnit.SECONDS);
        server.newHar("Cineworld");
    }

    @Test
    public void gotoPage() {
        driver.get(PageURL);
        driver.findElement(By.xpath("//section[@class='quickbook-component']"));
        driver.findElement(By.xpath("//button[@data-automation-id='searchByCinema']")).isEnabled();
        driver.findElement(By.xpath("//button[@data-automation-id='searchByFilm']")).isEnabled();
        driver.findElement(By.xpath("//a[@id='nowBooking_tab']")).isEnabled();
        driver.findElement(By.xpath("//a[@id='comingSoon_tab']")).isEnabled();
    }

    @Test
    public void expandMovieList() {
        driver.get(PageURL);
        int before= driver.findElements(By.xpath(PosterXPath)).size();
        driver.findElement(By.xpath("//img[@alt='Show more films']")).click();
        int after= driver.findElements(By.xpath(PosterXPath)).size();
        Assert.assertTrue(after > before);
    }

    @Test
    public void comingSoonList() {
        driver.get(PageURL);
        driver.findElement(By.xpath("//a[@id='comingSoon_tab']")).click();
        int posters = driver.findElements(By.xpath(PosterXPath)).size();
        Assert.assertTrue(posters > 0);
    }

    @Test
    public void manageHar() {
        Har har = server.getHar();
        List<HarEntry> X = har.getLog().getEntries();
        for(HarEntry he : X) {
            if (he.getRequest().getUrl().contains("google-analytics")) {
                System.out.println(he.getRequest().getUrl() + "\n");
            }
        }
    }

    @AfterClass
    public void tearDown() {
        server.stop();
        driver.quit();
    }

}