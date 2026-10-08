# Dream Experience — landing page

Página única (`index.html`) que adapta um template brutalista estilo Persona 5 para a
Dream Experience / Dream Factory. O conteúdo (textos, vídeos, cases, endereço) vem de
**https://dreamexperience.dreamfactory.com.br/**; a *mecânica visual* (clip-paths
rasgados, seções em skew, halftone, sombras duras, tipografia ransom-note) vem do
template original, preservada em `index.template.bak.html`.

## Rodar

**Duplo clique no `index.html` funciona.** A página não depende mais de servidor: todo
vídeo é `<video>` com arquivo local, então autoplay mudo roda igual em `file://` e em
HTTP. Para servir mesmo assim, há o `abrir-site.bat` (sobe o http-server, espera a
porta responder e abre o navegador) ou:

```bash
npx http-server -p 8899 -s --cors -c-1
```

Histórico, para não refazer o caminho: antes os três players eram embeds do YouTube.
Em `file://` o YouTube recusa o embed por falta de origin válido e pinta **"Erro de
configuração do player de vídeo — Erro 153"**; houve um fallback de poster clicável, e
depois controle via IFrame API. Tudo isso saiu quando os vídeos passaram a ser locais.

## Estrutura de `index.html`

Arquivo único, sem build. Ordem:

| Linhas | O quê |
|---|---|
| 1–328 | Script `aura-supabase-token-firewall` herdado do template. Inerte aqui (não há Supabase), mantido para não quebrar o pipeline de export de origem. |
| 329–~450 | `<head>`: Tailwind runtime local, fontes, GSAP, Lenis, bloco `<style>` com os tokens |
| 453+ | Corpo: PRELOADER → NAV → HERO (`#home`) → MARQUEE → SOBRE/FILME (`#sobre`) → CASES (`#cases`) → CONTATO (`#contato`) → FOOTER |
| final | `<script>` com toda a lógica (Lenis, ScrollTrigger, reveals, cursor, form) |

Dependências: Tailwind Play CDN e fontes estão em `assets/` (offline); GSAP 3.13,
ScrollTrigger, Lenis 1.3 e a Gotham vêm de CDN.

### Pastas

- `assets/` — runtime do template (Tailwind, iconify, fontes `.woff2`). Não editar.
- `img/` — imagens próprias do projeto. `logo1.png` é o símbolo oficial da Dream
  Factory (2560×2560, PNG com alpha); `favicon-32.png` e `apple-touch-icon.png` são
  derivados dele.
- `video/` — os três vídeos próprios da página, baixados do YouTube e servidos local:
  `hero-background.mp4`, `sobre-dream-experience.mp4`, `case-visa.mp4` (~7,6 MB no
  total). São **640×360**, a única resolução que o YouTube libera para download desses
  vídeos — dá upscale visível no filme, que é exibido com ~1060px. Se aparecerem os
  masters em alta, é só substituir os arquivos mantendo os nomes.
- `index.template.bak.html` — template original intacto, para consulta.

## Style guide

Cores amostradas do logo oficial, não inventadas:

| Token | Valor | Uso |
|---|---|---|
| `--df-blue` | `#0095DA` | acento primário, halftone, hover |
| `--df-orange` | `#F99D34` | acento secundário, CTA, o "X" do logotipo |
| `--df-black` | `#000000` | fundo |
| `--df-white` | `#FFFFFF` | texto, bordas |

O `img/logo1.png` tem o azul em `#008BD2`, um pouco mais escuro que o token. A
diferença é da arte original — o token veio de outro arquivo do logo. Mantenha
`#0095DA` na interface e use o PNG só como imagem.

Tipografia: **Gotham Black** (display), **Gotham Light** (corpo), com Anton/Oswald
locais de fallback. `Permanent Marker` nas palavras-destaque dos cases
("conteúdo & experiência", "creative data"…), reproduzindo o site de referência.

## Armadilhas (custaram tempo — não refaça)

**1. Não reintroduza o bloco `<style data-scroll-fix>`.** O template vinha com ele para
arquivamento offline e ele força `transform: none !important` e `opacity: 1 !important`
em praticamente tudo. Isso **mata todas as animações do GSAP**. Foi removido de
propósito.

**2. Nunca anime `width`/`height` de elemento com `aspect-ratio`.** O filme em `#sobre`
fazia isso: mudar a largura mudava a altura, o que deslocava a página inteira *durante*
o scroll e fazia o botão "Ver os cases" parar no lugar errado. Use `scale` (transform
não afeta layout). A altura do documento tem que ficar estável, senão `lenis.scrollTo`
erra o alvo.

**3. Não mova iframes no DOM.** `appendChild` num iframe recarrega o vídeo. O motion de
entrada dos players aplica a máscara no *elemento-pai* em vez de criar um wrapper
justamente por isso.

**4. `overflow: hidden` come a sombra dura.** Onde há máscara sobre um card com
`box-shadow-*`, use padding + margem negativa de mesmo valor para abrir espaço sem
mexer no layout.

**5. Alinhamentos entre blocos usam largura fixa compartilhada, não ajuste de fonte.**
O bloco do logo e a faixa de badges do hero são ambos `md:w-[360px]` — é o que garante
que as bordas direitas batam independente de como a Gotham renderiza.

**6. O filme do `#sobre` usa `max-w` em `vh`** (`max-w-[132vh]`), não `%`. É isso que
trava a altura em ~75vh e mantém as 4 quinas do card dentro da tela. Se aumentar,
confira que título + filme ainda cabem na dobra.

**7. Não volte a usar embed do YouTube aqui.** Já custou três rodadas: o `autoplay=1`
da URL é ignorado em boa parte dos contextos e o card fica parado no primeiro frame;
em `file://` o embed nem carrega (Erro 153); e controlar por IFrame API resolve o play
mas amarra a página a um script externo. Com `<video>` local, autoplay mudo, loop e o
botão de som são nativos e funcionam em qualquer protocolo.

**8. O Chrome pausa `<video>` fora da viewport por conta própria.** Por isso *todos* os
vídeos, inclusive o de fundo do hero, levam o ScrollTrigger de play/pause — sem ele o
hero não volta a tocar quando se sobe de novo até o topo.

**9. Os furos do `logo1.png` são transparentes, não brancos.** Sobre fundo escuro o
símbolo se fecha num disco azul sólido e perde a identidade. É por isso que o
`apple-touch-icon` é achatado em preto na geração (o iOS ignora alpha e preencheria de
branco), enquanto o favicon de aba mantém o alpha — assim o furo pega a cor da aba e
lê bem tanto no tema claro quanto no escuro.

## Favicon

Declarado no `<head>`, derivado de `img/logo1.png`:

| Arquivo | Tamanho | Fundo | Uso |
| --- | --- | --- | --- |
| `img/favicon-32.png` | 32×32 | transparente | aba do navegador |
| `img/logo1.png` | 2560×2560 | transparente | fallback `sizes="any"` |
| `img/apple-touch-icon.png` | 180×180 | preto | atalho iOS |

Os derivados foram gerados por reamostragem bicúbica do original. Para refazer depois
de trocar o logo, redimensione a partir do `logo1.png` mantendo essa divisão de fundo.
Há também um `theme-color` em `#0095DA`.

## Motion

- **Lenis** dirige o scroll; `lenis.raf` roda no ticker do GSAP e emite
  `ScrollTrigger.update`. Não adicione um `requestAnimationFrame` paralelo.
- **Textos** (`[data-split]`): split por palavra, sobem atrás de máscara
  (`yPercent 115 → 0`, `rotate +4 → 0`, `expo.out`). Splitter próprio — `SplitText` é
  plugin pago.
- **Players dos cases** (`[data-media]`): o **mesmo** motion dos textos, por pedido do
  cliente. O filme do `#sobre` é exceção — tem scrub próprio de `scale` e **não** leva
  `[data-media]`.
- **Nav**: um único ponto de corte (altura do header). Descendo, logo sai pela esquerda
  e menu pela direita; subindo, no mesmo ponto, voltam. `onEnter`/`onLeaveBack` já são
  simétricos por posição — não acrescente estado de direção.
- **Vídeos**: todos são `<video muted loop playsinline>`, dão play/pause ao entrar e
  sair da viewport, e só um toca com áudio por vez. O do hero também leva `autoplay`,
  por abrir já visível. O botão de som (`.sound-btn`) procura o `<video>` no próprio
  elemento-pai, então basta ficar ao lado dele no HTML.

## Abertura na hero

A página sempre abre no topo. São três peças, todas necessárias:

1. `history.scrollRestoration = 'manual'` — impede o browser de restaurar a posição
   num refresh.
2. Limpeza do `location.hash` via `replaceState` — impede o pulo para a âncora.
3. `lenis.scrollTo(0, { immediate: true, force: true })` no fim do preloader, que é a
   trava final.

**O bloco tem que ficar antes de `gsap.registerPlugin(ScrollTrigger)`.** O ScrollTrigger
guarda o `scrollRestoration` no registro e o repõe depois — com o bloco embaixo, o
ajuste é silenciosamente desfeito. Se for reordenar o início do script, confira isso.

Verificado em três cenários: refresh no fim da página, carga limpa com `#contato` na
URL, e navegação interna depois disso (que segue funcionando normalmente).

## Pendências conhecidas

- **Os três vídeos próprios estão em 360p** (limite do download). Trocar pelos masters
  em `video/`, mantendo os nomes, resolve sem tocar no código.
- **Mídia ainda hotlinkada**: os vídeos dos outros 5 cases e os logos dos clientes vêm
  do WordPress e do blob Azure da Dream Factory. Funciona, mas para produção vale
  baixar — o mesmo tratamento que os três de `video/` já receberam.
- **Formulário de contato sem backend.** Valida no cliente e exibe mensagem; falta um
  `fetch()` para um endpoint real. Marcado com comentário no código.
- **Vídeo do case Visa retorna 404 na origem** (`Conheça-a-Visa..mp4`, todas as
  variações de encoding). Substituído pelo do YouTube (`HvCZcczn6Yo`), hoje servido de
  `video/case-visa.mp4` como os demais.
- A seção **"Pessoas" foi removida** a pedido do cliente (conteúdo desatualizado). Se
  voltar, as fotos estão no blob em `/dreamexperience/2022/11/`.

## Convenções

- Comentários `ponytail:` marcam simplificações deliberadas e dizem quando trocar.
- Texto da interface em **pt-BR**; `<html lang="pt-BR">`.
- Ao mexer em espaçamento ou tamanho de bloco, **meça no browser** em vez de estimar —
  a Gotham vem de CDN e as métricas não são as do fallback.
