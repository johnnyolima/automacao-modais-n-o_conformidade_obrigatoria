/**
 * ========================================================================================
 * Script de Automação de Modais - Bootstrap Select (Final com reload automático)
 * ========================================================================================
 * Descrição:
 * - Percorre todos os modais da página com botão `editarNaoConformidade`.
 * - Clica no dropdown ("Não"), seleciona "Sim".
 * - Clica no botão "Atualizar" e fecha o modal.
 * - Controla janelas abertas (limite configurável).
 * - Recarrega a página principal ao final do processo.
 * ========================================================================================
 */

(function() {
  const MAXIMO_DE_JANELAS_ABERTAS = 3;
  const janelasAbertasPeloScript = [];

  function fecharTodasAsJanelas() {
    janelasAbertasPeloScript.forEach(j => { if (j && !j.closed) j.close(); });
    janelasAbertasPeloScript.length = 0;
    atualizarContadorDoBotao();
  }

  function atualizarContadorDoBotao() {
    const botao = document.getElementById('botao-fechar-janelas');
    if (botao) {
      const abertas = janelasAbertasPeloScript.filter(j => j && !j.closed).length;
      botao.innerText = `❌ Fechar Janelas Abertas (${abertas})`;
    }
  }

  function criarBotaoDeFechamento() {
    if (document.getElementById('botao-fechar-janelas')) return;
    const botao = document.createElement('button');
    botao.id = 'botao-fechar-janelas';
    botao.style = 'position: fixed; bottom: 20px; right: 20px; z-index:10000; padding:12px 20px; background:#dc3545; color:#fff; border:none; border-radius:8px; cursor:pointer; font-size:16px;';
    botao.innerText = '❌ Fechar Janelas Abertas (0)';
    botao.onclick = fecharTodasAsJanelas;
    document.body.appendChild(botao);
  }

  async function waitForElement(selector, context = document, timeout = 10000) {
    return new Promise((resolve, reject) => {
      const start = Date.now();
      const interval = setInterval(() => {
        const el = context.querySelector(selector);
        if (el) { clearInterval(interval); resolve(el); }
        else if (Date.now() - start > timeout) { clearInterval(interval); reject(`Elemento não encontrado: ${selector}`); }
      }, 200);
    });
  }

  async function confirmarModal(modal) {
    // 1. Clica no dropdown atual ("Não")
    const dropdownButton = modal.querySelector('.dropdown-toggle');
    if (!dropdownButton) { console.error('Dropdown não encontrado'); return; }
    dropdownButton.click();
    await new Promise(r => setTimeout(r, 300));

    // 2. Seleciona a opção "Sim"
    const opcaoSim = [...modal.querySelectorAll('.dropdown-menu.inner li a')]
      .find(a => a.querySelector('span.text')?.innerText.trim() === 'Sim');
    if (!opcaoSim) { console.error('Opção "Sim" não encontrada'); return; }
    opcaoSim.click();
    console.log('✅ Opção "Sim" selecionada');
    await new Promise(r => setTimeout(r, 300));

    // 3. Prepara envio em nova janela
    const form = modal.querySelector('form');
    if (form) {
      const windowName = 'submission_popup_' + Date.now();
      const novaJanela = window.open('', windowName, 'width=800,height=600,scrollbars=yes,resizable=yes');
      if (novaJanela) novaJanela.blur();
      form.target = windowName;
      janelasAbertasPeloScript.push(novaJanela);
      atualizarContadorDoBotao();
    }

    // 4. Clica no botão Atualizar
    const btnAtualizar = [...modal.querySelectorAll('button[type="submit"].btn.bg-bluegray')]
      .find(b => b.innerText.trim() === 'Atualizar');
    if (btnAtualizar) btnAtualizar.click();
    console.log('✅ Botão Atualizar clicado');

    // 5. Espera e fecha modal
    await new Promise(r => setTimeout(r, 1500));
    if ($('.modal.in').length > 0) $('.modal.in').modal('hide');

    // 6. Fecha janelas se exceder limite
    if (janelasAbertasPeloScript.length >= MAXIMO_DE_JANELAS_ABERTAS) {
      fecharTodasAsJanelas();
      await new Promise(r => setTimeout(r, 500));
    }
  }

  async function processarTodosModais() {
    criarBotaoDeFechamento();

    const botoesModais = [...document.querySelectorAll('button[data-toggle="modal"]')]
      .filter(b => b.value.includes('editarNaoConformidade'));

    for (const [i, botao] of botoesModais.entries()) {
      console.log(`🔹 Abrindo modal ${i+1}/${botoesModais.length}...`);
      botao.click();

      let modal;
      try { modal = await waitForElement('#editarNaoConformidade.modal.in'); } 
      catch(e) { console.warn('⚠️ Modal não abriu, pulando...'); continue; }

      await confirmarModal(modal);
    }

    console.log('✅ Todos os modais foram processados.');
    fecharTodasAsJanelas();

    // 7. Atualiza a página principal ao final
    console.log('🔄 Recarregando a página...');
    await new Promise(r => setTimeout(r, 2000));
    location.reload();
  }

  processarTodosModais();
})();
