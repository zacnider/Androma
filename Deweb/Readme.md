<p align="center">
  <img height="100" height="auto" src="https://raw.githubusercontent.com/Nodeist/Kurulumlar/main/logos/deweb.png">
</p>

# Deweb Kurulum Rehberi
## Donanım Gereksinimleri
Herhangi bir Cosmos-SDK zinciri gibi, donanım gereksinimleri de oldukça mütevazı.

### Minimum Donanım Gereksinimleri
 - 3x CPU; saat hızı ne kadar yüksek olursa o kadar iyi
 - 4GB RAM
 - 80GB Disk
 - Kalıcı İnternet bağlantısı (testnet sırasında trafik minimum 10Mbps olacak - üretim için en az 100Mbps bekleniyor)

### Önerilen Donanım Gereksinimleri
 - 4x CPU; saat hızı ne kadar yüksek olursa o kadar iyi
 - 8GB RAM
 - 200 GB depolama (SSD veya NVME)
 - Kalıcı İnternet bağlantısı (testnet sırasında trafik minimum 10Mbps olacak - üretim için en az 100Mbps bekleniyor)

## Deweb Full Node Kurulum Adımları
### Tek Script İle Otomatik Kurulum
Aşağıdaki otomatik komut dosyasını kullanarak Deweb fullnode'unuzu birkaç dakika içinde kurabilirsiniz.
Script sırasında size node isminiz (NODENAME) sorulacak!


```
wget -O DWS.sh https://raw.githubusercontent.com/Nodeist/Kurulumlar/main/Deweb/DWS && chmod +x DWS.sh && ./DWS.sh
```

### Kurulum Sonrası Adımlar

Doğrulayıcınızın blokları senkronize ettiğinden emin olmalısınız.
Senkronizasyon durumunu kontrol etmek için aşağıdaki komutu kullanabilirsiniz.
```
dewebd status 2>&1 | jq .SyncInfo
```

### Cüzdan Oluşturma
Yeni cüzdan oluşturmak için aşağıdaki komutu kullanabilirsiniz. Hatırlatıcıyı (mnemonic) kaydetmeyi unutmayın.
```
dewebd keys add $DWS_WALLET
```

(OPSIYONEL) Cüzdanınızı hatırlatıcı (mnemonic) kullanarak kurtarmak için:
```
dewebd keys add $DWS_WALLET --recover
```

Mevcut cüzdan listesini almak için:
```
dewebd keys list
```

### Cüzdan Bilgilerini Kaydet
Cüzdan Adresi Ekleyin:
```
DWS_WALLET_ADDRESS=$(dewebd keys show $DWS_WALLET -a)
DWS_VALOPER_ADDRESS=$(dewebd keys show $DWS_WALLET --bech val -a)
echo 'export DWS_WALLET_ADDRESS='${DWS_WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export DWS_VALOPER_ADDRESS='${DWS_VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile
```


### Doğrulayıcı oluştur
Doğrulayıcı oluşturmadan önce lütfen en az 1 dws'ye sahip olduğunuzdan (1 dws 1000000 udws'e eşittir) ve düğümünüzün senkronize olduğundan emin olun.

Cüzdan bakiyenizi kontrol etmek için:
```
dewebd query bank balances $DWS_WALLET_ADDRESS
```
> Cüzdanınızda bakiyenizi göremiyorsanız, muhtemelen düğümünüz hala eşitleniyordur. Lütfen senkronizasyonun bitmesini bekleyin ve ardından devam edin.

Doğrulayıcı Oluşturma:
```
dewebd tx staking create-validator \
  --amount 1999000udws \
  --from $DWS_WALLET \
  --commission-max-change-rate "0.01" \
  --commission-max-rate "0.2" \
  --commission-rate "0.07" \
  --min-self-delegation "1" \
  --pubkey  $(dewebd tendermint show-validator) \
  --moniker $DWS_NODENAME \
  --chain-id $DWS_ID \
  --fees 250udws
```



## Kullanışlı Komutlar
### Servis Yönetimi
Logları Kontrol Et:
```
journalctl -fu dewebd -o cat
```

Servisi Başlat:
```
systemctl start dewebd
```

Servisi Durdur:
```
systemctl stop dewebd
```

Servisi Yeniden Başlat:
```
systemctl restart dewebd
```

### Node Bilgileri
Senkronizasyon Bilgisi:
```
dewebd status 2>&1 | jq .SyncInfo
```

Validator Bilgisi:
```
dewebd status 2>&1 | jq .ValidatorInfo
```

Node Bilgisi:
```
dewebd status 2>&1 | jq .NodeInfo
```

Node ID Göser:
```
dewebd tendermint show-node-id
```

### Cüzdan İşlemleri
Cüzdanları Listele:
```
dewebd keys list
```

Mnemonic kullanarak cüzdanı kurtar:
```
dewebd keys add $DWS_WALLET --recover
```

Cüzdan Silme:
```
dewebd keys delete $DWS_WALLET
```

Cüzdan Bakiyesi Sorgulama:
```
dewebd query bank balances $DWS_WALLET_ADDRESS
```

Cüzdandan Cüzdana Bakiye Transferi:
```
dewebd tx bank send $DWS_WALLET_ADDRESS <TO_WALLET_ADDRESS> 10000000udws
```

### Oylama
```
dewebd tx gov vote 1 yes --from $DWS_WALLET --chain-id=$DWS_ID
```

### Stake, Delegasyon ve Ödüller
Delegate İşlemi:
```
dewebd tx staking delegate $DWS_VALOPER_ADDRESS 10000000udws --from=$DWS_WALLET --chain-id=$DWS_ID --gas=auto --fees 250udws
```

Payını doğrulayıcıdan başka bir doğrulayıcıya yeniden devretme:
```
dewebd tx staking redelegate <srcValidatorAddress> <destValidatorAddress> 10000000udws --from=$DWS_WALLET --chain-id=$DWS_ID --gas=auto --fees 250udws
```

Tüm ödülleri çek:
```
dewebd tx distribution withdraw-all-rewards --from=$DWS_WALLET --chain-id=$DWS_ID --gas=auto --fees 250udws
```

Komisyon ile ödülleri geri çekin:
```
dewebd tx distribution withdraw-rewards $DWS_VALOPER_ADDRESS --from=$DWS_WALLET --commission --chain-id=$DWS_ID
```

### Doğrulayıcı Yönetimi
Validatör İsmini Değiştir:
```
seid tx staking edit-validator \
--moniker=NEWNODENAME \
--chain-id=$DWS_ID \
--from=$DWS_WALLET
```

Hapisten Kurtul(Unjail):
```
dewebd tx slashing unjail \
  --broadcast-mode=block \
  --from=$DWS_WALLET \
  --chain-id=$DWS_ID \
  --gas=auto --fees 250udws
```


Node Tamamen Silmek:
```
sudo systemctl stop dewebd
sudo systemctl disable dewebd
sudo rm /etc/systemd/system/deweb* -rf
sudo rm $(which dewebd) -rf
sudo rm $HOME/.deweb* -rf
sudo rm $HOME/deweb -rf
sed -i '/DWS_/d' ~/.bash_profile
```
