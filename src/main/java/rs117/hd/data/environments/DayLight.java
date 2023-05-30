package rs117.hd.data.environments;

import lombok.extern.slf4j.Slf4j;

import java.time.LocalDate;
import java.time.LocalTime;



@Slf4j
public enum DayLight {

    DAY(LocalTime.of(7, 0), true),
    NIGHT(LocalTime.of(17, 0), false);

    private LocalTime startTime;
    private boolean shadowsEnabled;


    /**
     * This is a season(month) based changed.
     * December/June = -90 degrees
     * March/September = -45/-135 degrees
     */
    private static final int START_YAW = -45;
    private static final int END_YAW = -135;

    //private static final int DAY_LENGTH = 1; // The length of a day in minutes (if no config)

    DayLight(LocalTime startTime, boolean shadowsEnabled) {
        this.startTime = startTime;
        this.shadowsEnabled = shadowsEnabled;
    }

    public boolean isShadowsEnabled() {
        return shadowsEnabled;
    }

    public static DayLight getTimeOfDay(LocalTime currentTimeOfDay, int dayLength) {

        int currentTime = timeToSecondsInt(currentTimeOfDay) % (dayLength * 60);

        float start = (float)DAY.startTime.getHour() / 24;
        float end = (float)NIGHT.startTime.getHour() / 24;
        float time = (float)currentTime / 60 / dayLength;

        if ( time >= start && time < end ) {
            return DayLight.DAY;
        }
        else
        {
            return DayLight.NIGHT;
        }
    }

    private float getLightDirection(LocalTime currentTimeOfDay, int dayLength) {

        return getTimeFloat(currentTimeOfDay, dayLength);
    }

    private float getTimeFloat(LocalTime currentTimeOfDay , int dayLength) {
        int currentTime = timeToMillisecondsInt(currentTimeOfDay) % (dayLength * 60 * 1000);

        float time = (float)currentTime / 60 / 1000 / dayLength;

        float dayTime = 12/24f;

        return time;
    }

    private float percentageOfSeason(LocalDate currentDate) {
        float month = currentDate.getMonthValue() + (currentDate.getDayOfMonth() / (float) currentDate.lengthOfMonth());
        float normalizedMonth = month <= 6 ? month : month - 7;
        return normalizedMonth / 6;
    }

    public float getCurrentPitch(LocalTime currentTime, int dayLength) {
        //LocalTime currentTimeOfDay = LocalTime.of(currentTime / 60, currentTime % 60);
        return getLightDirection(currentTime, dayLength) * 360 + 90;
    }

    public float getCurrentYaw(LocalDate currentDate) {
        return percentageOfSeason(currentDate) * (END_YAW - START_YAW) + START_YAW;
    }

    public static int timeToSecondsInt(LocalTime time) {
        return time.getHour() * 3600 + time.getMinute() * 60 + time.getSecond();
    }

    public static int timeToMillisecondsInt(LocalTime time) {
        return time.getHour() * 3600 * 1000 + time.getMinute() * 60 * 1000 + time.getSecond() * 1000 + time.getNano() / 1000000;
    }

    public static float timeScaled(LocalTime time) {
        return timeToSecondsInt(time) / 86400f;
    }

    public static int getTransitionDuration(int dayLength) {
        return dayLength * 2500;
    }
}
