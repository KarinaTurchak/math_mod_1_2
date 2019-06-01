# 1
# ������ ������ � ��� ������� 19 ����������� ����������� ������� � 2016 ����, 
# ���� ��� �������� ������� ����� �������� ���������� �� ���������� 4 ����, � 15 ��������� ������������
#53.710509, 91.454428

# ��������� ����������:
library(tidyverse)
library(rnoaa)
library(lubridate)

# �������� ������� � ������� ��� �������:
af = c(0.00,0.00,0.00,32.11, 26.31,25.64,23.20,18.73,16.30,13.83,0.00,0.00)
bf = c(0.00, 0.00, 0.00, 11.30, 9.26, 9.03,8.16, 6.59, 5.73, 4.87, 0.00, 0.00)
df = c(0.00,0.00, 0.00, 0.33, 1.00, 1.00, 1.00, 0.32, 0.00, 0.00, 0.00, 0.00)
Kf = 300 #  ����������� ������������� ���
Qj = 1600 # ������������ ������ ��������
Lj = 2.2 #  ����� ������ �������� � �������� ���������
Ej = 25 #   ����������� ��������� ��������

#station_data = ghcnd_stations()
#write.csv(station_data, "station_data.csv")

station_data = read.csv("station_data.csv")
# ������� ������ ������������
abakan = data.frame(id = "ABAKAN", latitude = 53.710509,  longitude = 91.454428)
#������ �������, ��������������� ���������
abakan_around = meteo_nearby_stations(lat_lon_df = abakan, station_data = station_data,
                                           limit = 15, var = "TAVG", 
                                           year_min = 2012, year_max = 2015)
#�������� �������
all_data = tibble()
#������� � ������� ������ ��� �������
for (i in 1:length(abakan_around))
{
  # ��������� �������:
  abakan_id = abakan_around[["ABAKAN"]][["id"]][i]
  # �������� ������ ��� �������:
  data = meteo_tidy_ghcnd(stationid = abakan_id,
                          var="TAVG",
                          date_min="2012-01-01",
                          date_max="2015-12-31")
  #��������� ������ � �������
  all_data = bind_rows(all_data, data %>%
                         #������� ������� ��� ����������� �� ���� � ������
                         mutate(year = year(date), month = month(date)) %>%
                         group_by(month, year) %>%
                         #������ ��������� ������� �������� ����������� �� ������ �� ������ ��� ��� �������
                         summarise (tavg = sum(tavg[tavg>50], na.rm = TRUE)/10 )
  )
}

# ��������� � ������� ���������� � ������� clean_data.
clean_data = all_data %>%
  # ������� ������� month ��� ����������� ������:
  group_by(month) %>%
  # ������ �������� d � c���� �������� ��������� ��� ������ �������:
  summarise(s = mean(tavg, na.rm = TRUE)) %>%
  #������� ������ �� ������� � ����������� d
  # ������� ������� ��� �������:
  mutate (a = af, b = bf, d = df) %>%
  # ���������� ����������� ��� ������� ������:
  mutate (fert = ((a + b * 1.0 * s) * d * Kf) / (Qj * Lj * (100-Ej)) )
#�������� �������, ����������� ������� � ���������� ���� � 2003 ���� ��������� (�/��):
Yield = sum(clean_data$fert); Yield
