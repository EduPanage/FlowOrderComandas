from flask import Flask, request, jsonify

app = Flask(__name__)

@app.route('/api/pedido', methods=['POST'])
def receber_pedido():
    # Verifica se a requisição é do tipo JSON.
    if not request.is_json:
        return jsonify({"erro": "Requisição deve ser JSON"}), 400

    # Pega os dados JSON do corpo da requisição.
    dados_pedido = request.get_json()

    # Loga os dados recebidos para demonstração.
    print("---------------------------------------")
    print("PEDIDO RECEBIDO")
    print(f"Mesa: {dados_pedido.get('mesa')}")
    print("Itens:")
    for item in dados_pedido.get('itens', []):
        print(f"  - Produto: {item['produto']}, Quantidade: {item['quantidade']}, Obs: {item['observacao']}")
    print(f"Status: {dados_pedido.get('status')}")
    print(f"Horário: {dados_pedido.get('horario')}")
    print("---------------------------------------")

    # **Adicione sua lógica para salvar os dados no Firebase aqui.**
    # Você pode usar a biblioteca 'firebase-admin' para Python.
    # Exemplo: db.collection('pedidos').add(dados_pedido)

    # Retorna uma resposta de sucesso para o aplicativo.
    return jsonify({"mensagem": "Pedido recebido com sucesso!"}), 200

if __name__ == '__main__':
    # Roda o servidor Flask em http://localhost:5000
    # O host '0.0.0.0' permite que o servidor seja acessível de fora do localhost,
    # o que é necessário para o emulador Flutter.
    try:
        app.run(host='0.0.0.0', port=5000, debug=True)
    except Exception as e:
        print(f"Erro ao iniciar o servidor: {e}")
