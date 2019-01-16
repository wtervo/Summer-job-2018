**********************************
Alustava käyttöohje kesätyökoodiin
**********************************

Mikäli Swarm-datasta haluaa löytää FAC-kääntökulman varsinaisella ohjelmallani,
täytyy ensin ESAn .cdf-tiedostoista poistaa CHAOS-malli. Tämä tapahtuu remove_CHAOS.m
-koodilla (koodien lopulliset nimet tulevat olemaan kuvaavampia...). Jotta koodi
voidaan suorittaa, täytyy cdfData-kansiossa olla vähintään yksi em. .cdf-
datatiedosto ESAn sivuilta. Tämän jälkeen ohjelma lukee kaikki kansiossa olevat
tiedostot ja käsittelee ne yksitellen (skippaaminen on mahdollista) kertoen
käyttäjälle minkä päivän data on kyseessä ja kummalta (A vai C) satelliitilta.
Tämän jälkeen käyttäjän tulee valita halutun päivän datavälin aloitushetki
tunteina ja minuutteina välilyönnillä erotettuna, eli muotoa "21 20", "5 48" jne.
Datavälin loppuhetki valitaan samalla tavalla, jonka jälkeen ohjelma laskee
kyseiselle tiedostolle CHAOS-mallin poiston. Tässä prosessissa voi kestää
hyvin kauan, erityisesti jos valittu dataväli on pitkä ja kyseessä on HR-data.

Koodi luo laskennan lopuksi tiedoston muotoa swarmMag_<tähän_cdf_tiedoston_pvm>.mat,
jonne laskettu data tallennetaan ja jota seuraava koodi hyödyntää. Eli ts.
test1-koodia ei tarvitse suorittaa kuin kerran jokaiselle .cdf-tiedostolle.




Kun CHAOS-malli on poistettu, voidaan kiertokulma, FAC ym. laskea rotated_FAC.m-ohjelmalla.
Koodi käsittelee jokaisen sen kanssa samassa kansiossa olevan test1-ohjelman luoman 
tiedoston yksitellen (edelleen voi skipata tiedostoja). Ensiksi koodi kysyy kuinka
suuri on kiertokulmien löytämiseen käytettävä ikkunanleveys (koodin output-tekstissä 
viitataan tähän nimellä binsize - täytynee korjata tämä ja moni muu tuloste myöhemmin).
Testitiedostojen perusteella näyttäisi, että parhaat arvot ovat LR-datalle välillä
80-100 ja HR-datalle välillä 4500-5000.

Seuraavaksi koodi kysyy kuinka paljon ikkunat menevät laskennan aikana toistensa päälle,
eli kuinka monta yhteistä datapistettä niillä on. Käytännössä tämä tarkoittaa sitä, että
kuinka paljon laskentapiste siirtyy jokaisen kulman määrittämisen jälkeen. Esim. jos
ikkunan leveys on 150 datapistettä ja overlap-valinta on 149, siirtyy laskenta yhden
datapisteen kerrallaan.

Tämän jälkeen ohjelma kysyy |B'_x| / |B'_y| -suhteen raja-arvoa. Jos kyseinen suhde
ylittää valitun arvon jossain pisteessä, ei kyseiselle pisteelle lasketa FAC:tä
(oikeasti lasketaan, mutta aiemmin laskettu arvo vain muutetaan NaN:ksi).

Neljäs käyttäjältä vaadittava input on valinta siitä miten kiertokulma theta
lasketaan. Valittavana on 1) B_x-komponentin minimointi, 2) B_x min, josta
on vähennetty tietyn välin <B_X> ja 3) derivaatta. Testien perusteella
paras laskentatapa on 2), koska se ottaa huomioon elektrojetin vaikutuksen
tuloksiin, toisin kuin kaksi muuta tapaa. Jos ejetin vaikutus on mitätön,
on paras metodi 1).

Viimeinen valinta on y/n-valinta siitä, että plotataanko tulokset.

Vaikka käyttäjä ei haluaisikaan plotteja, tallentaa ohjelma lopuksi jokaista alkuperäistä
tiedostoa kohtaan oman tiedostonsa muotoa swarm_bdot_<tähän_cdf_tiedoston_pvm>.mat.


Muutamia huomautuksia:
######################

Kaikissa input-kohdissa on virheellisten syötteiden varalta tarkistukset, joten typoja yms.
ei tarvitse pelätä. En ainakaan vielä ole onnistunut löytämään syötettä, jolla ohjelma kaatuisi.

Mikäli ohjelman suorittamisen haluaa keskeyttää missä pisteessä tahansa, kuten vaikkapa yhden
datatiedoston käsittelyn jälkeen, jos muut eivät kiinnosta, on helpoin tapa lopettaa ohjelma
painamalla ctrl+C. Laiskuuttani en jaksanut jokaiseen input-kohtaan erikseen koodata "quit"
tms. -komentoa.

Jos ohjelma sattuukin jostain syystä käyttäytymään omituisesti, kannattaa tarkistaa onko
Matlabiin jäänyt roikkumaan jotain muuttujia vaikkapa ohjelman keskeytyksen jäljiltä
tai sitten vaihtoehtoisesti poistaa/siirtää kaikki swarmMag_*.mat ja swarm_bdot_*.mat
-tiedostot ja aloittaa prosessi alusta.

Jos käyttöliittymän rämpyttäminen käy hermoille, tapahtuu varsinainen laskenta koodeissa
calc_field_rot.m ja calc_field_rot_1step.m (yhden "askeleen versio), mikäli haluaa rakentaa
niiden ympärille jotain itselle mieluisampaa. Kulman laskenta tapahtuu tiedostossa
find_theta.m.
