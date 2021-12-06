# Top Rebel ( İsyancılar Sıralaması )

> Eklenti Terörist(Mahkum) oyuncuların Anti-Terörist(Gardiyan) oyuncularından 1 kişi öldürdüğünde ona 1 puan verir ve onu tabloya aktarır.

## Eklenti Kurulum:

1. WebFTP/FTP üzerinden addons/sourcemod/configs yoluna gidiyoruz, **databases.cfg** dosyasına giriyoruz ve aşağıda size verdiğim kısmı oraya kopyalayıp yapıştırıyorsunuz.
____________
    "toprebel"
	{
		"driver"			"sqlite"
		"database"			"toprebel"
	}
____________

2. WebFTP/FTP üzerinden addons/sourcemod/plugins yoluna gidiyoruz ve size verdiğim addons/sourcemod/plugins/**toprebel.smx** eklentisini oraya atıyoruz.

3. Sunucunuzu restartlayın ve eklentiniz çalışacaktır.

> Önemli bilgi: Eklenti jb dışında çalışıyor ama puan vermiyor oyuncular sadece kendi sıralamasına bakması için.

## Eklenti Komutları:

### Sıralamayı açma komutları:
> sm_toprebel
> sm_topisyan
> sm_isyancilar

### Sıralamayı panele loglama komutları:
> sm_toprebellog
> sm_topisyanlog
> sm_isyancilarlog

### Sıralamayı sıfırlama komutları:
> sm_xtoprebel
> sm_xtopisyan
> sm_xisyancilar