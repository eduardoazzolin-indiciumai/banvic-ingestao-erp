# Data Engineer Certification: Instruções do desafio

## A certificação
Este desafio busca avaliar a sua capacidade de planejar e desenvolver a infraestrutura e fluxo de ingestão de dados. Por meio do uso das técnicas e ferramentas apresentadas ao longo do curso, você deverá construir uma POC de infraestrutura e pipeline de dados de forma a organizar a informação num ambiente centralizado de fácil acesso.

## Contexto
O Banco Vitória S.A., também conhecido como BanVic, foi fundado em São Paulo em 2010, com uma visão inovadora de oferecer serviços bancários eficientes tanto em agências físicas quanto no ambiente digital. Com uma equipe de 100 colaboradores dedicados, o BanVic cresceu para se tornar uma instituição financeira nacional de destaque. O banco sempre foi focado em proporcionar aos clientes experiências bancárias transparentes e convenientes. No entanto, à medida que a instituição expandiu suas operações e serviços, surgiu a necessidade de aprimorar a compreensão de seus dados para impulsionar ainda mais a excelência em seus produtos e serviços.

Nossa história começa quando a CEO do BanVic, Sofia Oliveira, percebe que utilizar dados para a tomada de decisão é a chave para elevar o banco a novos patamares. Ela acredita que entender profundamente as operações e comportamentos dos clientes pode levar a melhorias significativas nos serviços oferecidos.

Sofia convoca uma reunião com a equipe de liderança, incluindo o Diretor de Tecnologia, André Tech, a Diretora Comercial, Camila Diniz, e o recém-contratado Analista de Dados, Lucas Johnson. Cada um deles traz perspectivas únicas para a mesa.

André Tech, o especialista em tecnologia, está animado com a ideia de implementar técnicas avançadas de análise de dados para otimizar as operações internas do banco. Há tempos André e sua equipe fazem análises manuais para o banco e ele não gostaria de seguir dessa forma por já conhecer os riscos deste formato.

Camila Diniz, por outro lado, não está convencida que este é o caminho. Ela acredita que o BanVic pode investir mais em marketing e melhorar a segmentação dos clientes nas cidades onde o banco já está estabelecido, sendo esse um caminho mais rápido e já conhecido pelo BanVic. Sua postura pode colocar em risco o projeto, pois sua equipe hoje detém parte dos dados comerciais importantes para a estruturação digital da empresa e isso pode acarretar em burocracias e atrasos em relação a acessos e permissões.

Por fim, Lucas Johnson, apaixonado por dados, propõe um projeto piloto para compreender os dados de crédito do BanVic. Seu intuito é iniciar a jornada de dados gerando valor para uma área crítica do banco e assim convencer a Diretora que essa iniciativa pode ser muito benéfica para a companhia.

A equipe concorda que a implementação de um projeto de análise de dados bem-sucedido pode proporcionar insights valiosos, melhorando a eficiência operacional e a experiência do cliente. No entanto, todos são conscientes dos desafios técnicos e da importância de escolher as ferramentas certas.

Em um servidor da nuvem estão os dados do ERP, CRM e marketing. Atualmente as análises do BanVic são realizadas em planilhas e apresentações. Eles não possuem nada em ferramentas de BI, mas estão abertos a utilizar ferramentas como PowerBI ou Databricks AI/BI dentre outros.

Para materializar esta cultura, a CEO deseja implementar o desenvolvimento e adoção de um Dashboard na área comercial, gerenciada pela Diretora Camila Diniz. Camila é bastante cética quanto ao papel da área de dados e defende investimentos tradicionais em marketing para elevar a performance. O objetivo da área comercial é aumentar a quantidade de transações por cliente, mantendo-os ativos e diminuindo o risco de churn.

Além disso, a CEO quer avaliar e saber onde precisa investir esforço no próximo trimestre. Olhando para os dados históricos, quais são as alavancas que realmente movem o ponteiro? Ela não quer saber apenas o que tem relação com o sucesso, ela precisa de um ranking quantitativo do que é mais impactante para saber onde o retorno é garantido estatisticamente.

## Objetivo do desafio
O objetivo é montar um pipeline de ingestão e infraestrutura para que analistas possam consumir os dados de forma centralizada usando uma base inicial composta pelas 7 cópias das tabelas do ERP enviadas no arquivo `banvic_data.zip`.

## Etapas do desafio
Para desenvolver os entregáveis, é essencial passar pelas etapas abaixo, que simulam o ciclo de vida de engenharia de dados:

1. **Infraestrutura como Código (IaC), Conteinerização e Kubernetes:**
   1. Você deverá preparar a estrutura de execução (Airflow) e armazenamento (postgreSQL ou MiniO) utilizando um ambiente Kubernetes local (MiniKube/Kind).
2. **Desenvolvimento do Pipeline de Ingestão (ELT):**
   1. Utilizando o arquivo `banvic_data.zip` como fonte de dados (simulando um sistema legado ou arquivos on-premise), construa um pipeline de ingestão.
   2. Você deve utilizar ferramentas como Meltano ou Embulk para realizar a extração e o carregamento (Load) dos dados em um destino (Data Lake ou Data Warehouse simulado em Postgres ou MinIO).
   3. Configure corretamente os Extractors (Taps) e Loaders (Targets) para garantir a integridade dos dados.
3. **Orquestração de Tarefas:**
   1. Desenvolva DAGs no Apache Airflow para orquestrar a execução dos pipelines de ingestão criados na etapa anterior.
   2. A DAG deve conter tarefas bem definidas (Tasks), respeitando as dependências entre elas.
   3. Utilize Sensores (Sensors) se necessário para verificar a disponibilidade dos arquivos antes da execução.
4. **Monitoramento e Tratamento de Falhas:**
   1. Implemente estratégias básicas de monitoramento. Sua orquestração deve ser capaz de lidar com falhas (retries) e garantir a idempotência das execuções.
5. **Documentação Técnica:**
   1. Documente a arquitetura da solução, explicando as escolhas das ferramentas e como executar o projeto localmente.
6. **Criação de apresentação final e gravação de vídeo.**

## O que será avaliado
Os critérios para aprovação do aluno serão os seguintes:

1. **Domínio de Infraestrutura:** Capacidade de subir o ambiente utilizando containers (Docker), IaC e Kubernetes, garantindo isolamento e reprodutibilidade.
2. **Implementação de Ingestão de Dados:** Configuração correta de ferramentas de ingestão, demonstrando entendimento de conexões com fontes e destinos e a movimentação eficiente dos dados.
3. **Orquestração e Boas Práticas de Airflow:** Criação de DAGs organizadas, uso correto de Operadores, definição de dependências e agendamento adequado.
4. **Qualidade e Resiliência do Código:** O código deve ser limpo, modular e capaz de lidar com erros.
5. **Segurança e Gerenciamento de Segredos:** Capacidade de não expor credenciais no código.
6. **Apresentação da solução:** Clareza na explicação da arquitetura e demonstração funcional do pipeline rodando.

## Apresentação e entrega do desafio
O trabalho consiste em entregar a solução de engenharia para o BanVic, nos seguintes arquivos:

1. **Repositório Git (Link ou Zip):** Contendo todo o código do projeto. Isso inclui:
   1. Arquivos de Infraestrutura.
   2. Arquivos de configuração da ingestão.
   3. Pasta `dags/` com o código Python das DAGs do Airflow.
2. **Arquivo README.md:** Documentação técnica contendo:
   1. Diagrama da arquitetura de dados desenhada.
   2. Instruções passo a passo de como subir o ambiente e rodar o pipeline.
   3. Explicação sobre a estratégia de ingestão adotada.
3. **Vídeo de 03 a 05 minutos:** Condução da apresentação técnica. É essencial incluir:
   1. Demonstração do processo de deploy do ambiente.
   2. A interface do Airflow mostrando a DAG sendo executada com sucesso.
   3. Verificação final dos dados chegando no destino.
