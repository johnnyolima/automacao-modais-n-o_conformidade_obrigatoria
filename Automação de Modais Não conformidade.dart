async function confirmarModal(modal) {
    // 1. Encontra o select original do Bootstrap Select
    const select = modal.querySelector('select');
    if (!select) { console.error('Select não encontrado'); return; }

    // 2. Define o valor para "Sim"
    const opcaoSim = [...select.options].find(opt => opt.text.trim() === 'Sim');
    if (!opcaoSim) { console.error('Opção "Sim" não encontrada no select'); return; }
    select.value = opcaoSim.value;

    // 3. Dispara evento de mudança para o Bootstrap atualizar a UI
    select.dispatchEvent(new Event('change', { bubbles: true }));

    console.log('✅ Opção "Sim" selecionada no select');

    // 4. Prepara envio em nova janela
    const form = modal.querySelector('form');
    if (form) {
        const windowName = 'submission_popup_' + Date.now();
        const novaJanela = window.open('', windowName, 'width=800,height=600,scrollbars=yes,resizable=yes');
        if (novaJanela) novaJanela.blur();
        form.target = windowName;
        janelasAbertasPeloScript.push(novaJanela);
        atualizarContadorDoBotao();
    }

    // 5. Clica no botão Atualizar
    const btnAtualizar = [...modal.querySelectorAll('button[type="submit"].btn.bg-bluegray')]
        .find(b => b.innerText.trim() === 'Atualizar');
    if (btnAtualizar) btnAtualizar.click();
    console.log('✅ Botão Atualizar clicado');

    // 6. Espera e fecha modal
    await new Promise(r => setTimeout(r, 1500));
    if ($('.modal.in').length > 0) $('.modal.in').modal('hide');

    // 7. Fecha janelas se exceder limite
    if (janelasAbertasPeloScript.length >= MAXIMO_DE_JANELAS_ABERTAS) {
        fecharTodasAsJanelas();
        await new Promise(r => setTimeout(r, 500));
    }
}
