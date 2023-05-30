package rs117.hd.data.environments;

import lombok.extern.slf4j.Slf4j;

import java.time.Instant;
import java.time.LocalDate;

@Slf4j
public enum DayLight {

    DAY(7 * 3600, true),
    NIGHT(17 * 3600, false);

    private int startTimeSeconds;
    private boolean shadowsEnabled;

    /**
     * This is a season(month) based changed.
     * December/June = -90 degrees
     * March/September = -45/-135 degrees
     */
    private static final int START_YAW = -45;
    private static final int END_YAW = -135;

    DayLight(int startTimeSeconds, boolean shadowsEnabled) {
        this.startTimeSeconds = startTimeSeconds;
        this.shadowsEnabled = shadowsEnabled;
    }

    public boolean isShadowsEnabled() {
        return shadowsEnabled;
    }

    public static DayLight getTimeOfDay(Instant currentTime, int dayLength) {
        long currentTimeSeconds = currentTime.getEpochSecond() % (dayLength * 60L);

        float start = (float) DAY.startTimeSeconds / (24 * 3600);
        float end = (float) NIGHT.startTimeSeconds / (24 * 3600);
        float time = (float) currentTimeSeconds / (60 * dayLength);

        if (time >= start && time < end) {
            return DayLight.DAY;
        } else {
            return DayLight.NIGHT;
        }
    }

    private float getLightDirection(Instant currentTime, int dayLength) {
        return getTimeFloat(currentTime, dayLength);
    }

    private float getTimeFloat(Instant currentTime, int dayLength) {
        long currentTimeMillis = currentTime.toEpochMilli() % ((long) dayLength * 60 * 1000);

        return (float) currentTimeMillis / (60 * 1000 * dayLength);
    }

    private float percentageOfSeason(LocalDate currentDate) {
        float month = currentDate.getMonthValue() + (currentDate.getDayOfMonth() / (float) currentDate.lengthOfMonth());
        float normalizedMonth = month <= 6 ? month : month - 7;
        return normalizedMonth / 6;
    }

    public float getCurrentPitch(Instant currentTime, int dayLength) {
        return getLightDirection(currentTime, dayLength) * 360 + 90;
    }

    public float getCurrentYaw(LocalDate currentDate) {
        return percentageOfSeason(currentDate) * (END_YAW - START_YAW) + START_YAW;
    }

    public static int timeToSecondsInt(Instant time) {
        return (int) (time.getEpochSecond() % (24 * 3600));
    }

    public static int timeToMillisecondsInt(Instant time) {
        return (int) (time.toEpochMilli() % (24 * 3600 * 1000));
    }

    public static float timeScaled(Instant time) {
        return timeToSecondsInt(time) / 86400f;
    }

    public static int getTransitionDuration(int dayLength) {
        return dayLength * 2500;
    }
}