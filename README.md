# Backend Web com Haskell+Scotty


- Estrutura e conteúdo do README:


  3. Processo de desenvolvimento: comentários pessoais sobre o desenvolvimento, com evidências de compreensão, incluindo versões com erros e tentativas de solução
  4. Orientações para execução: instalação de dependências, etc.
  5. Resultado final: demonstrar execução em GIF animado ou vídeo curto (máximo 60s)
  6. Referências e créditos (incluindo alguns prompts, se aplicável)

## 1. Identificação

- Nome: Diogo Rocha 
- Curso: Sistemas de informação

---

## 2. Tema/objetivo

O projeto é um serviço web para análise de tipagem competitiva de Pokémon. Dado um time (até 6 Pokémon), o sistema calcula:

- Fraquezas e resistências de cada membro (multiplicadores 4x, 2x, 0.5x, 0.25x, 0x)
- Cobertura do time (percentual de tipos cobertos)
- Sugestão de um novo membro baseado nos tipos não cobertos
- Sprites oficiais dos Pokémon (integração com PokeAPI)

A lógica principal é implementada em funções **puras** (`Logic.hs`), separadas do servidor web (Scotty), aplicando conceitos de programação funcional como imutabilidade, funções de alta ordem (`map`, `filter`, `foldr`) e tipos algébricos.

---

## 3. Processo de desenvolvimento

O desenvolvimento seguiu etapas incrementais:

1. **Scaffolding e tipos** – Definição dos tipos de dados (`TeamMember`, `DamageRelation`, etc.) usando `DeriveGeneric` para facilitar a serialização JSON.
2. **Lógica pura** – Implementação da tabela de efetividade (mapeamento tipo → multiplicador) e funções de cálculo de fraquezas, cobertura e sugestão. Testada independentemente com HUnit.
3. **Integração com PokeAPI** – Funções para buscar tipos e sprites (`Api.hs`). Inicialmente com parsing JSON complexo, simplificado após erros de decodificação.
4. **Servidor Scotty** – Rotas `GET /health`, `POST /analyze` e `GET /suggest`. CORS configurado para permitir requisições do frontend.
5. **Frontend** – HTML/CSS/JS com Pokédex dinâmica (scroll infinito, cache de detalhes). A maior dificuldade foi alinhar os nomes dos campos no JSON (campo `tmName` vs `name`). Após vários testes com `curl` e logs, descobriu-se que o Scotty retorna o corpo como `BSL.ByteString` (não `TL.Text`) e que a decodificação falhava por causa do nome do campo. A solução foi renomear os campos do record para `name` e `types` e usar `eitherDecode`.


**Erros e tentativas:**

- **Erro de compilação:** `Couldn't match expected type ‘TL.Text’ with actual type ‘BSL.ByteString’`. Descobrimos que `body` no Scotty retorna `ByteString` lazy. Corrigi usando `bodyBS <- body` diretamente.
- **Erro de parse JSON:** `key "trTeam" not found`. O campo `trTeam` não correspondia ao `"team"` do frontend. Refatorei `Types.hs` para usar o campo `team` e adaptei as instâncias `FromJSON`.
- **CORS:** O frontend (porta 8000) não conseguia acessar o backend (porta 3000). Ativei CORS com `cors (const $ Just simpleCorsResourcePolicy)`.
- **Frontend com caracteres estranhos:** O arquivo HTML era servido sem codificação UTF-8. Corrigi usando `TLEnc.decodeUtf8` no `Main.hs`.

A parte mais desafiadora foi entender o sistema de tipos do Scotty e do Aeson, mas após depuração com logs e testes no `ghci`, tudo foi resolvido.

---

## 4. Testes

Os testes unitários (arquivo `test/Spec.hs`) verificam as funções puras:

- `calculateDamageMultiplier`: casos de 2x, 0.5x, 0x, combinações 4x.
- `calculateWeaknesses`: verifica fraquezas e resistências de Pokémon específicos (Charizard, Water).
- `calculateCoverage`: testa cobertura do time (ex: time inicial com Charizard/Blastoise/Venusaur).
- `findUncoveredTypes`: garante que tipos não cobertos são identificados.
- `suggestNewMember` e `suggestForTypes`: verificam se a sugestão retorna um tipo e exemplos.

Todos os testes passam (12 testes OK). Foram usados `HUnit` e `assertBool`/`assertEqual`.
os testes foram feitos da maneira logica que seria usado na biblioteca pytest do python 

---

## 5. Execução

### Dependências

- Stack (gerenciador de pacotes Haskell)
- GHC 9.6.6 (ou versão compatível)

### Comandos

```bash
# Clonar o repositório (ou acessar a pasta)
# obs: deixei tudo nesta pasta por que não sabia se em um procimo trabalho usaria o mesmo codespace
cd pokemon_analyzer

# Compilar e rodar os testes unitários
stack test

# Iniciar o servidor backend (porta 3000)
stack run
```
---

## 6. Deploy

**Link do serviço publicado:** [https://pokemon-analyzer-qv5g.onrender.com](https://pokemon-analyzer-qv5g.onrender.com)

**Processo de deploy:**

1. **Escolha da plataforma** – Optou-se pelo **Render** por ser o indicado pela professora  e suportar aplicações Docker.
2. **Preparação do ambiente** – Foi criado um `Dockerfile` em dois estágios (build com `fpco/stack-build` e runtime com `ubuntu:22.04` para compatibilidade de `glibc`).
3. **Configuração do Render** – Um arquivo `render.yaml` (blueprint) foi criado na raiz do repositório, com `runtime: docker` e apontando para o `Dockerfile`.
4. **Problemas enfrentados**:
   - Inicialmente, o Render rejeitava o blueprint com `services[0].image must be provided` (corrigido mudando de `runtime: image` para `runtime: docker`).
   - Erro de `stack.yaml.lock` não encontrado – resolvido removendo a referência ao arquivo no `Dockerfile`.
   - Erro de `GLIBC_2.34 not found` – resolvido trocando a imagem de runtime de `ubuntu:focal` para `ubuntu:22.04`.
5. **Sucesso** – Após as correções, o build foi concluído e o serviço ficou disponível no link acima. O deploy está funcionando perfeitamente.

---

## 7. Resultado final

![demonstracao1](/pokemon_analyzer/gifs/demo1.gif)

![demonstracao2](/pokemon_analyzer/gifs/demo2.gif)

**O que está sendo demonstrado nos GIF :**

**Adição de Pokémon** – Clica-se em um Pokémon na Pokédex (scroll infinito) e ele é adicionado ao time à esquerda, com sprite oficial.

**Remoção de Pokémon** – Remove-se um membro do time com o botão "REMOVER".

**Limpeza do time** – Botão "LIMPAR" remove todos os Pokémon.

**Análise do time** – Ao clicar em "ANALISAR", o sistema:
   - Mostra a cobertura percentual do time (barra animada).
   - Lista os tipos não cobertos.
   - Exibe, para cada Pokémon, suas fraquezas e resistências (com multiplicadores 4x, 2x, 0.5x, 0.25x).
   - Apresenta uma sugestão de novo membro (tipo, motivo e exemplos de Pokémon).

---

## 8. Uso de IA 

### 8.1 Ferramentas de IA utilizadas

ChatGPT (modelo GPT-4o, plano gratuito) – utilizado para gerar código inicial no frontend.

GitHub Copilot (modelo Gemini 2.0 Flash) – utilizado para autocompletar funções repetitivas e gerar a tabela de efetividade de tipos.



---

### 8.2 Interações relevantes com IA

#### Interação 1
Objetivo da consulta: Corrigir erro de compilação envolvendo o tipo do body no Scotty (Couldn't match expected type ‘TL.Text’ with actual type ‘BSL.ByteString).

Trecho do prompt ou resumo fiel: "Como resolver ‘Couldn't match expected type TL.Text with actual type BSL.ByteString’ no Scotty?"

O que foi aproveitado: A sugestão de usar bodyBS <- body diretamente e aplicar eitherDecode.

O que foi modificado ou descartado: A IA sugeriu usar jsonData, mas isso gerava erro 422. Adotamos a abordagem manual com eitherDecode e logs para depuração.

#### Interação 2
Objetivo da consulta: Resolver erro de parse JSON (key "trTeam" not found).

Trecho do prompt ou resumo fiel: "O erro ‘key trTeam not found’ aparece. Como fazer o Aeson usar ‘team’?"

O que foi aproveitado: A orientação de renomear o campo do record para team e ajustar as instâncias FromJSON/ToJSON.

O que foi modificado ou descartado: A IA sugeriu escrever uma instância manual complexa; optamos por renomear o campo e usar DeriveGeneric, mais simples e direto.

#### Interação 3
Objetivo da consulta: Melhorar o frontend para carregar todos os Pokémon da PokeAPI sem travar.

Trecho do prompt ou resumo fiel: "Como fazer a Pokédex exibir todos os Pokémon (mais de 1000) sem travar o navegador?"

O que foi aproveitado: Estratégia de scroll infinito, cache de detalhes (pokemonCache) e carregamento assíncrono dos sprites.

O que foi modificado ou descartado: A IA sugeriu usar IntersectionObserver (implementado) e também pré-carregar todos os dados em um array, o que foi descartado para evitar consumo excessivo de memória.

#### Interação 4
Objetivo da consulta: Entender como configurar o deploy no Render com Docker.

Trecho do prompt ou resumo fiel: "Como criar um Dockerfile para uma aplicação Haskell com Stack e fazer deploy no Render?"

O que foi aproveitado: Estrutura básica do Dockerfile em dois estágios (build e runtime) e o arquivo render.yaml.

O que foi modificado ou descartado: A IA inicialmente sugeriu usar runtime: image, o que causou erro. Corrigimos para runtime: docker e especificamos o dockerfilePath.

#### Interação 5
Objetivo da consulta: Corrigir erro de stack.yaml.lock não encontrado durante o build no Render.

Trecho do prompt ou resumo fiel: "Erro: ‘/pokemon_analyzer/stack.yaml.lock’: not found. Como resolver?"

O que foi aproveitado: Remover a referência ao arquivo no Dockerfile, pois ele não está versionado.

O que foi modificado ou descartado: A IA sugeriu adicionar o arquivo ao repositório, mas optamos por removê-lo do COPY por ser gerado automaticamente.
 

---

### 8.3 Exemplo de erro, limitação ou sugestão inadequada da IA

Caso: Quando tentei usar jsonData com TeamRequest, a IA afirmou que funcionaria, mas o servidor retornava erro 422. A sugestão não considerava que o campo do record (trTeam) não correspondia à chave "team" do JSON enviado pelo frontend. Precisei depurar manualmente com eitherDecode e logs para descobrir que a chave esperada era trTeam. A IA não identificou a raiz do problema, apenas sugeriu usar jsonData sem ajustar os nomes dos campos.

Como corrigi: Renomeei o campo para team e adaptei o Logic.hs e Api.hs para usar name e types. Além disso, substituí jsonData por eitherDecode manual com logs detalhados.

### 8.4 Comentário pessoal sobre o processo envolvendo IA
o uso da IA foi de grande ajuda para acelerar a escrita da tabela de efetividades e para a estrutura do frontend, mas em questões específicas do Haskell a IA forneceu respostas erradas e incompletas fazendo com que o trabalho demorace mais que o necessario, depois de perceber os erros principalmente nas partes de tratamento como ByteString vs Text no Scotty eu preferi usar a IA como meio para fazer coisas repitidas mas na parte de codigo bruta acabei usando o ghci para depurar o codigo e achar erros 



---

## 9. Referências e créditos

Documentação do Scotty: https://hackage.haskell.org/package/scotty

Documentação do Aeson: https://hackage.haskell.org/package/aeson

PokeAPI (dados de Pokémon): https://pokeapi.co/

Material de aula da disciplina: Notas de aula sobre programação funcional e Scotty (Prof. [Andrea]).

Render Deploy Guide: https://render.com/docs/deploy-haskell 

Inspiração para a Pokédex: adaptação de exemplos de scroll infinito da MDN (https://developer.mozilla.org/en-US/docs/Web/API/Intersection_Observer_API)

Código de exemplo de tabela de efetividade: baseado no conhecimento de tipos Pokémon da comunidade, com adaptações próprias.

como meu sistema era parecido com a ideia do Gabriel Quadros tivemos uma conversa inicial de como poderiamos fazer 