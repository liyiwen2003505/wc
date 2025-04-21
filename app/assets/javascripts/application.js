document.addEventListener("DOMContentLoaded", function () {
    let modal = document.getElementById("authorModal");
    let openModalBtn = document.getElementById("openAuthorModal");
    let closeModalBtn = document.getElementById("closeAuthorModal");
    console.log("modal"+modal);

    // 打开模态层
    openModalBtn.addEventListener("click", function () {
        modal.style.display = "block";
    });

    // 关闭模态层
    closeModalBtn.addEventListener("click", function () {
        modal.style.display = "none";
    });

    // 避免点击模态层内部关闭
    document.querySelector(".modal-content").addEventListener("click", function (event) {
        event.stopPropagation(); // 防止点击子元素时关闭模态框
    });

    // 避免模态层关闭时提交表单
    modal.addEventListener("click", function (event) {
        if (event.target === modal) {
            modal.style.display = "none";
        }
    });

    // 分页 & 搜索不会关闭模态框
    document.getElementById("searchAuthors").addEventListener("click", function (event) {
        event.preventDefault();
        event.stopPropagation();
        loadAuthors();
    });

    document.getElementById("prevPage").addEventListener("click", function (event) {
        event.preventDefault();
        event.stopPropagation();
        if (currentPage > 1) {
            currentPage--;
            loadAuthors();
        }
    });

    document.getElementById("nextPage").addEventListener("click", function (event) {
        event.preventDefault();
        event.stopPropagation();
        currentPage++;
        loadAuthors();
    });
});