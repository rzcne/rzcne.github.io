// 创建并添加元素
function createDengContainer() {
    const container = document.createElement('div');
    container.className = 'deng-container';

    // 从当前脚本的 URL 获取参数
    const scriptSrc = document.currentScript.src;
    const urlParams = new URLSearchParams(scriptSrc.split('?')[1]); // 获取 '?'
    const customText = urlParams.get('text'); // 获取参数名为'text'的值

    // 将获取的文本分割为字符数组，如果没有提供文本，则使用默认的“新年快乐”
    const texts = customText ? customText.split('') : ['新', '年', '快', '乐'];

    // 获取网页的字体样式
    const computedStyle = window.getComputedStyle(document.body);
    const fontFamily = computedStyle.fontFamily || 'Arial, sans-serif'; // 默认字体

    texts.forEach((text, index) => {
        const box = document.createElement('div');
        box.className = 'deng-box';

        const deng = document.createElement('div');
        deng.className = 'deng';

        const xian = document.createElement('div');
        xian.className = 'xian';

        const dengA = document.createElement('div');
        dengA.className = 'deng-a';

        const dengB = document.createElement('div');
        dengB.className = 'deng-b';

        const dengT = document.createElement('div');
        dengT.className = 'deng-t';
        dengT.textContent = text;
        dengT.style.fontFamily = fontFamily; // 设置动态字体

        dengB.appendChild(dengT);
        dengA.appendChild(dengB);
        deng.appendChild(xian);
        deng.appendChild(dengA);

        const shuiA = document.createElement('div');
        shuiA.className = 'shui shui-a';

        const shuiC = document.createElement('div');
        shuiC.className = 'shui-c';
        const shuiB = document.createElement('div');
        shuiB.className = 'shui-b';

        shuiA.appendChild(shuiC);
        shuiA.appendChild(shuiB);
        deng.appendChild(shuiA);
        box.appendChild(deng);
        container.appendChild(box);
    });

    document.body.appendChild(container);
}

// 添加CSS样式
function addStyles() {
    const style = document.createElement('style');
    style.type = 'text/css';
    style.textContent = `
        .deng-container {
            position: fixed; /* 使容器固定 */
            right: 20px; /* 固定在右边 */
            top: 20px; /* 固定在顶部 */
            display: flex;
            flex-direction: column; /* 垂直排列 */
            gap: 15px; /* 灯笼之间的间距 */
            pointer-events: none;
        }
        .deng-box {
            display: flex; /* 使用flex布局 */
            justify-content: center; /* 水平居中 */
        }
        .deng {
            position: relative;
            width: 100px; /* 统一宽度 */
            height: 80px; /* 统一高度 */
            background: rgba(216, 0, 15, .8);
            border-radius: 50% 50%;
            animation: swing 3s infinite ease-in-out;
            box-shadow: -5px 5px 50px 4px #fa6c00;
        }
        /* 其余CSS样式保持不变... */
    `;
    document.head.appendChild(style);
}

// 引入时调用
function init() {
    addStyles();
    createDengContainer();
}

// 调用初始化函数
init();
