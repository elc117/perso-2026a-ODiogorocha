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

---

## 6. Deploy

Link do serviço publicado: <complete aqui>

Descreva de forma breve como você realizou o deploy a partir da base e das orientações fornecidas. Caso não tenha conseguido, explique o que tentou.

---

## 7. Resultado final

Apresente o resultado final do trabalho, na forma de GIF animado ou vídeo curto (máximo 60s)

Você também pode acrescentar uma breve explicação sobre o que está sendo demonstrado.

---

## 8. Uso de IA 

### 8.1 Ferramentas de IA utilizadas

Liste as principais ferramentas de IA utilizadas, com suas versões/modelos/planos. Por exemplo, ChatGPT Free com GPT-5.2 Thinking, GitHub Copilot com Gemini 2.0 Flash, Antigravity com Claude Sonnet 4.6 (Thinking), etc.

---

### 8.2 Interações relevantes com IA

Inclua **de 3 a 5 interações relevantes** com ferramentas de IA.


#### Interação 1

- **Objetivo da consulta:**  
- **Trecho do prompt ou resumo fiel:**  
- **O que foi aproveitado:**  
- **O que foi modificado ou descartado:**  

#### Interação 2

- **Objetivo da consulta:**  
- **Trecho do prompt ou resumo fiel:**  
- **O que foi aproveitado:**  
- **O que foi modificado ou descartado:**  

#### Interação 3 

- **Objetivo da consulta:**  
- **Trecho do prompt ou resumo fiel:**  
- **O que foi aproveitado:**  
- **O que foi modificado ou descartado:**  

#### Interação 4 (opcional)

- **Objetivo da consulta:**  
- **Trecho do prompt ou resumo fiel:**  
- **O que foi aproveitado:**  
- **O que foi modificado ou descartado:**  

#### Interação 5 (opcional)

- **Objetivo da consulta:**  
- **Trecho do prompt ou resumo fiel:**  
- **O que foi aproveitado:**  
- **O que foi modificado ou descartado:**  

---

### 8.3 Exemplo de erro, limitação ou sugestão inadequada da IA

Descreva **ao menos um caso** em que a IA:

- errou
- foi incompleta
- sugeriu algo inadequado ou incompreensível
- produziu código que precisou de correção relevante

Explique brevemente o que aconteceu e como você percebeu ou corrigiu o problema.

---

### 8.4 Comentário pessoal sobre o processo envolvendo IA

Escreva um breve comentário pessoal sobre o processo envolvendo IA.

Você pode comentar, por exemplo:

- algo que passou a compreender melhor
- uma dificuldade que conseguiu superar
- uma limitação que ainda sente
- como o uso de IA ajudou ou atrapalhou em certos momentos.

---

## 9. Referências e créditos

Liste referências e créditos de forma detalhada, com título e URL, incluindo, quando aplicável:

- sites consultados
- documentações
- materiais de aula
- colegas
- trechos de código adaptados
- imagens, vídeos 

Exemplo:

- Documentação do Scotty: ...
- Documentação do Render: ...
- Material de aula da disciplina: ...
- Vídeo sobre Scotty: ...