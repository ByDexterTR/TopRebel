# Top Rebel ( İsyancılar Sıralaması )

> Eklenti Terörist(Mahkum) oyuncuların Anti-Terörist(Gardiyan) oyuncularından 1 kişi öldürdüğünde ona 1 puan verir ve onu tabloya aktarır.

## Eklenti Kurulum:

1. WebFTP/FTP üzerinden addons/sourcemod/configs yoluna gidiyoruz, **databases.cfg** dosyasına giriyoruz ve aşağıda size verdiğim kısmı oraya kopyalayıp yapıştırıyorsunuz.
	
	"toprebel"
	{
		"driver"			"sqlite"
		"database"			"toprebel"
	}
	
2. WebFTP/FTP üzerinden addons/sourcemod/plugins yoluna gidiyoruz ve size verdiğim addons/sourcemod/plugins/**toprebel.smx** eklentisini oraya atıyoruz.

3. Sunucunuzu restartlayın ve eklentiniz çalışacaktır.

> Önemli bilgi: Eklenti jb dışında çalışıyor ama puan vermiyor oyuncular sadece kendi sıralamasına bakması için.

## Eklenti Komutları:

#### Sıralamayı açma komutları:
1. sm_toprebel
2. sm_topisyan 
3. sm_isyancilar

#### Sıralamayı panele loglama komutları:
1. sm_toprebellog 
2. sm_topisyanlog 
3. sm_isyancilarlog

#### Sıralamayı sıfırlama komutları:
1. sm_xtoprebel 
2. sm_xtopisyan 
3. sm_xisyancilar
