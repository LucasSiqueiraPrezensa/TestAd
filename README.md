# AppTestGoogleAdManager-iOS 🚀

Este projeto é uma **Prova de Conceito (PoC)** para demonstrar a integração do **Google Ad Manager** em um aplicativo iOS moderno, utilizando **UIKit** e o formato de **Custom Native Ads (Anúncios Nativos Personalizados)**.

O objetivo principal é validar a exibição do formato **Shortz** (vídeos curtos) integrados de forma fluida em um carrossel vertical com autoplay e loop contínuo.

## 📱 Demo

| Shortz Video Integration |
|--------------------------|
| <video width="300" autoplay loop muted playsinline controls>
  <source src="docs/shortz_demo.mp4" type="video/mp4">
</video> |

---

## 🛠️ Tecnologias Utilizadas

- **Swift**
- **UIKit**
- **Google Mobile Ads SDK (GAM)**
- **UICollectionView**
- **AutoLayout**
- **VideoControllerDelegate**

---

## 🏗️ Implementação

### 1. Inicialização do Carrossel Vertical
A interface principal utiliza um `UICollectionView` configurado para comportamento semelhante ao feed vertical do Shortz/TikTok.

```swift
private lazy var carousel: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .vertical
    layout.minimumLineSpacing = 0

    let collection = UICollectionView(
        frame: .zero,
        collectionViewLayout: layout
    )

    collection.isPagingEnabled = true
    collection.showsVerticalScrollIndicator = false

    return collection
}()
```

### 2. Configuração do AdLoader
O carregamento dos anúncios é realizado utilizando `AdLoader` com suporte a múltiplos anúncios e `Custom Native Ads`.

```swift
let multipleAdsOptions = MultipleAdsAdLoaderOptions()
multipleAdsOptions.numberOfAds = 5

adLoader = AdLoader(
    adUnitID: "/32352161/formatos/ShortzVideo",
    rootViewController: self,
    adTypes: [.customNative],
    options: [multipleAdsOptions]
)
```

### 3. Custom Targeting
O projeto utiliza `customTargeting` para segmentar anúncios específicos do formato Shortz.

```swift
let request = AdManagerRequest()

request.customTargeting = [
    "tvg_pos": "SHORTZ"
]

adLoader?.load(request)
```

### 4. Validação de Mídia Antes da Renderização
Antes de adicionar o anúncio ao feed, o projeto realiza uma validação para garantir que existe mídia renderizável disponível.

Essa verificação evita cenários onde:
- O anúncio possui apenas assets de texto
- O vídeo/imagem está indisponível
- O `MediaContent` retorna erro
- O anúncio possui aspect ratio inválido

```swift
func adLoader(_ adLoader: AdLoader, didReceive customNativeAd: CustomNativeAd) {
    printDebugAd(customNativeAd)
    
    let mediaContent = customNativeAd.mediaContent
    let hasVideo = mediaContent.hasVideoContent
    let hasImage = mediaContent.mainImage != nil && mediaContent.aspectRatio > 0
    let hasRenderableMedia = hasVideo || hasImage

    guard hasRenderableMedia else {
        print("❌ Sem mídia renderizável")
        return
    }

    customNativeAd.delegate = self
    customAds.append(customNativeAd)

    DispatchQueue.main.async {
        self.carousel.reloadData()
    }
}
```

### 5. Renderização do Conteúdo de Vídeo
O `MediaView` é utilizado para renderizar vídeos e imagens do anúncio dinamicamente.

```swift
mediaView.mediaContent = mediaContent
mediaView.isHidden = false
```

O sistema identifica automaticamente se o anúncio possui:
- Vídeo (`hasVideoContent`)
- Imagem (`mainImage`)
- Aspect ratio válido

### 6. Autoplay e Loop de Vídeo
Para melhorar a experiência do formato Shortz, o projeto implementa autoplay contínuo utilizando `VideoControllerDelegate`.

Além da reprodução automática, o loop contínuo evita que o botão de play seja exibido novamente ao término do vídeo, mantendo a experiência fluida e semelhante a plataformas de vídeos curtos.

```swift
func videoControllerDidEndVideoPlayback(_ videoController: VideoController) {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
        videoController.play()
    }
}
```

---

## 📋 Funcionalidades Implementadas

- [x] Integração com Google Ad Manager.
- [x] Carregamento de múltiplos anúncios nativos personalizados.
- [x] Suporte a Custom Targeting (`tvg_pos: SHORTZ`).
- [x] Feed vertical paginado estilo Shortz/TikTok.
- [x] Renderização dinâmica de vídeo e imagem.
- [x] Autoplay e loop automático de vídeos.
- [x] Validação de mídia antes da renderização.
- [x] Controle de Impressões e Cliques.
- [x] Placeholder de carregamento enquanto a mídia é renderizada.
- [x] Fallback automático para anúncios sem vídeo.
- [x] Debug de assets disponíveis do anúncio.

---

## 🧱 Estrutura do Projeto

### `ViewController`
Responsável por:
- Configurar o `UICollectionView`
- Inicializar o `AdLoader`
- Receber anúncios do Google Ad Manager
- Validar disponibilidade da mídia
- Gerenciar impressões e cliques
- Atualizar o feed dinamicamente

### `AdCarouselCell`
Responsável por:
- Renderizar `MediaView`
- Exibir título do anúncio
- Gerenciar loading state
- Executar autoplay e loop de vídeos
- Configurar fallback visual

---

## 🚀 Como Executar

1. Clone o repositório.
2. Instale as dependências do Google Mobile Ads SDK.
3. Configure o projeto no Xcode.
4. Utilize um dispositivo físico para testes de vídeo.
5. Execute o aplicativo.

---

## 📌 Observações Técnicas

- O formato utilizado é `Custom Native Ads`.
- O projeto foi desenvolvido com foco em mídia vertical.
- O autoplay depende do conteúdo disponibilizado pelo inventário do GAM.
- O `recordImpression()` é executado manualmente após renderização da mídia.
- O projeto suporta anúncios com vídeo e imagem.
- Existe validação preventiva para impedir renderização de anúncios sem mídia válida.

---

Desenvolvido como referência técnica para implementações de Google Ad Manager no iOS.
