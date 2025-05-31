📝 Descrição
Este projeto é um sistema de agendamentos para salão, desenvolvido com Flutter. O aplicativo permite:

Cadastrar agendamentos com nome do cliente, serviço e data/hora.

Listar todos os agendamentos salvos.

Editar ou excluir agendamentos.

Buscar agendamentos pelo nome do cliente ou serviço.

Todos os dados ficam salvos localmente no dispositivo.

🚀 Como rodar o projeto
✔️ Pré-requisitos:
Ter o Flutter instalado na sua máquina.

Estar com um emulador Android ou dispositivo físico conectado.

✔️ Passos:
Clone ou abra o projeto no seu editor (VSCode, Android Studio ou outro).

No terminal, execute:

arduino
Copiar
Editar
flutter pub get
Isso vai instalar as dependências necessárias.

Conecte um dispositivo físico ou abra um emulador.

Execute o projeto com:

flutter run
📦 Dependências utilizadas
shared_preferences: usada para armazenar os agendamentos localmente no dispositivo.

uuid: usada para gerar IDs únicos para cada agendamento.

📚 Estrutura do Projeto
O projeto foi desenvolvido inteiramente dentro do arquivo main.dart, sem separação em pastas.

O main.dart contém:

O modelo Agendamento.

A classe de serviço AgendamentoService (responsável por salvar, carregar, adicionar, editar e excluir agendamentos).

As telas:

ListaPage: tela inicial, onde você visualiza, busca, edita e exclui agendamentos.

CadastroPage: tela onde você cria ou edita um agendamento.

🔧 Funcionalidades principais
✅ Cadastrar novos agendamentos.

✅ Editar agendamentos existentes.

✅ Excluir agendamentos.

✅ Busca por nome do cliente ou serviço.

✅ Salvamento local (os dados permanecem no dispositivo mesmo após fechar o app).

💡 Observações importantes
Todas as funcionalidades estão centralizadas no main.dart.

As dependências são essenciais para o funcionamento. Não remova shared_preferences nem uuid do projeto.

Este projeto salva os dados localmente, portanto, ele não utiliza banco de dados online.
