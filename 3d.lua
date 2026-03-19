<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Vision Audio Pro · 3D立体UI</title>
    <style>
        body {
            margin: 0;
            overflow: hidden;
            font-family: 'SF Pro Display', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
            background-color: #000;
            color: white;
        }
        /* 提示信息 - 仅在静态截图时可见，3D场景运行时会被覆盖，作为优雅降级 */
        .info {
            position: absolute;
            bottom: 20px;
            left: 20px;
            color: rgba(255,255,255,0.5);
            font-size: 14px;
            z-index: 10;
            pointer-events: none;
            text-shadow: 0 2px 10px rgba(0,0,0,0.5);
            backdrop-filter: blur(5px);
            padding: 8px 16px;
            border-radius: 40px;
            background: rgba(20,20,30,0.3);
            border: 0.5px solid rgba(255,255,255,0.15);
        }
        .info i {
            font-style: normal;
            color: #ff9f4b;
        }
    </style>
</head>
<body>
    <div class="info">🎧 <i>Vision Audio Pro</i> · 沉浸式3D播放器 (拖拽视角 / 自动旋转)</div>

    <!-- 引入 Three.js 核心库和扩展控件 -->
    <script type="importmap">
        {
            "imports": {
                "three": "https://unpkg.com/three@0.126.0/build/three.module.js",
                "three/addons/": "https://unpkg.com/three@0.126.0/examples/jsm/"
            }
        }
    </script>

    <script type="module">
        import * as THREE from 'three';
        import { OrbitControls } from 'three/addons/controls/OrbitControls.js';
        import { CSS2DRenderer, CSS2DObject } from 'three/addons/renderers/CSS2DRenderer.js';

        // --- 初始化场景、摄像机、渲染器 ---
        const scene = new THREE.Scene();
        scene.background = new THREE.Color(0x0a0a14); // 深空底色
        
        // 添加一些星芒背景粒子 (简单的fog或者粒子)
        scene.fog = new THREE.FogExp2(0x0a0a14, 0.002);

        const camera = new THREE.PerspectiveCamera(45, window.innerWidth / window.innerHeight, 0.1, 1000);
        camera.position.set(5, 3, 8);
        camera.lookAt(0, 0, 0);

        // WebGL渲染器
        const renderer = new THREE.WebGLRenderer({ antialias: true, alpha: false });
        renderer.setSize(window.innerWidth, window.innerHeight);
        renderer.shadowMap.enabled = true; // 开启阴影以获得更真实立体感
        renderer.shadowMap.type = THREE.PCFSoftShadowMap;
        renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
        renderer.toneMapping = THREE.ACESFilmicToneMapping;
        renderer.toneMappingExposure = 1.2;
        document.body.appendChild(renderer.domElement);

        // CSS2渲染器用于文字标签 (模拟Vision Pro浮空面板)
        const labelRenderer = new CSS2DRenderer();
        labelRenderer.setSize(window.innerWidth, window.innerHeight);
        labelRenderer.domElement.style.position = 'absolute';
        labelRenderer.domElement.style.top = '0px';
        labelRenderer.domElement.style.left = '0px';
        labelRenderer.domElement.style.pointerEvents = 'none'; // 让点击穿透到canvas
        document.body.appendChild(labelRenderer.domElement);

        // --- 控制器 (允许用户拖拽查看3D立体) ---
        const controls = new OrbitControls(camera, renderer.domElement);
        controls.enableDamping = true;
        controls.dampingFactor = 0.05;
        controls.autoRotate = true;
        controls.autoRotateSpeed = 0.8;
        controls.enableZoom = true;
        controls.enablePan = false;
        controls.maxPolarAngle = Math.PI / 2.2; // 限制角度
        controls.minDistance = 3;
        controls.maxDistance = 15;
        controls.target.set(0, 0.5, 0);

        // --- 灯光系统: 营造立体感和玻璃质感 ---
        
        // 环境光均匀照亮
        const ambientLight = new THREE.AmbientLight(0x404060);
        scene.add(ambientLight);

        // 主光源 - 产生阴影和高光
        const mainLight = new THREE.DirectionalLight(0xfff5e6, 1.2);
        mainLight.position.set(2, 5, 5);
        mainLight.castShadow = true;
        mainLight.receiveShadow = true;
        mainLight.shadow.mapSize.width = 1024;
        mainLight.shadow.mapSize.height = 1024;
        const d = 10;
        mainLight.shadow.camera.left = -d;
        mainLight.shadow.camera.right = d;
        mainLight.shadow.camera.top = d;
        mainLight.shadow.camera.bottom = -d;
        mainLight.shadow.camera.near = 2;
        mainLight.shadow.camera.far = 20;
        scene.add(mainLight);

        // 辅助背光
        const backLight = new THREE.PointLight(0x4466ff, 0.5);
        backLight.position.set(-3, 1, -3);
        scene.add(backLight);

        // 氛围点光源 (给玻璃增加反射亮点)
        const pointLight1 = new THREE.PointLight(0xffaa66, 0.8);
        pointLight1.position.set(2, 3, 4);
        scene.add(pointLight1);
        
        const pointLight2 = new THREE.PointLight(0x66aaff, 0.6);
        pointLight2.position.set(-2, 1, 5);
        scene.add(pointLight2);

        // 添加一些微小的闪烁粒子 (营造空间感)
        const starsGeometry = new THREE.BufferGeometry();
        const starsCount = 800;
        const starPositions = new Float32Array(starsCount * 3);
        for (let i = 0; i < starsCount * 3; i += 3) {
            starPositions[i] = (Math.random() - 0.5) * 200;
            starPositions[i+1] = (Math.random() - 0.5) * 200;
            starPositions[i+2] = (Math.random() - 0.5) * 200;
        }
        starsGeometry.setAttribute('position', new THREE.BufferAttribute(starPositions, 3));
        const starsMaterial = new THREE.PointsMaterial({ color: 0xffffff, size: 0.15, transparent: true, opacity: 0.6 });
        const stars = new THREE.Points(starsGeometry, starsMaterial);
        scene.add(stars);

        // --- 核心UI元素: 浮空玻璃底板 (一个半透明的磨砂平面，作为UI底座) ---
        const basePlateGeometry = new THREE.CylinderGeometry(3.8, 3.8, 0.15, 64);
        // 使用玻璃材质
        const basePlateMaterial = new THREE.MeshPhysicalMaterial({
            color: 0xaaccff,
            emissive: 0x111122,
            metalness: 0.1,
            roughness: 0.2,
            transparent: true,
            opacity: 0.25,
            clearcoat: 1.0,
            clearcoatRoughness: 0.1,
            reflectivity: 0.3,
            side: THREE.DoubleSide
        });
        const basePlate = new THREE.Mesh(basePlateGeometry, basePlateMaterial);
        basePlate.receiveShadow = true;
        basePlate.castShadow = true;
        basePlate.position.set(0, -0.1, 0);
        basePlate.rotation.x = 0;
        basePlate.rotation.z = 0;
        scene.add(basePlate);

        // 底座边缘光带 (装饰)
        const ringGeometry = new THREE.TorusGeometry(3.8, 0.03, 32, 100);
        const ringMaterial = new THREE.MeshStandardMaterial({ color: 0x5f9eff, emissive: 0x224488 });
        const ring = new THREE.Mesh(ringGeometry, ringMaterial);
        ring.rotation.x = Math.PI / 2;
        ring.position.set(0, 0.0, 0);
        scene.add(ring);

        // 内部小圆环装饰
        const innerRingGeo = new THREE.TorusGeometry(2.5, 0.02, 16, 80);
        const innerRingMat = new THREE.MeshStandardMaterial({ color: 0xffaa55, emissive: 0x442200 });
        const innerRing = new THREE.Mesh(innerRingGeo, innerRingMat);
        innerRing.rotation.x = Math.PI / 2;
        innerRing.rotation.z = 0.3;
        innerRing.position.set(0, 0.05, 0);
        scene.add(innerRing);

        // --- 3D黑胶唱片 (主角) ---
        const vinylGroup = new THREE.Group();
        
        // 唱片主体 (黑色圆盘)
        const discGeo = new THREE.CylinderGeometry(2.2, 2.2, 0.2, 64);
        const discMat = new THREE.MeshStandardMaterial({
            color: 0x111111,
            roughness: 0.4,
            metalness: 0.2,
            emissive: 0x000000
        });
        const disc = new THREE.Mesh(discGeo, discMat);
        disc.receiveShadow = true;
        disc.castShadow = true;
        disc.rotation.x = 0; // 默认平躺，但我们让整个group旋转
        vinylGroup.add(disc);

        // 唱片标签 (中心圆)
        const labelGeo = new THREE.CylinderGeometry(0.8, 0.8, 0.21, 32);
        const labelMat = new THREE.MeshStandardMaterial({
            color: 0xffaa33,
            emissive: 0x331100,
            roughness: 0.3,
            metalness: 0.1
        });
        const label = new THREE.Mesh(labelGeo, labelMat);
        label.position.set(0, 0, 0);
        label.receiveShadow = true;
        label.castShadow = true;
        vinylGroup.add(label);

        // 唱片沟槽装饰 (几个细圆环)
        for (let i = 0; i < 3; i++) {
            const grooveGeo = new THREE.TorusGeometry(1.6 - i*0.4, 0.02, 16, 64);
            const grooveMat = new THREE.MeshStandardMaterial({ color: 0x888888, emissive: 0x222222 });
            const groove = new THREE.Mesh(grooveGeo, grooveMat);
            groove.rotation.x = Math.PI / 2;
            groove.position.set(0, 0.11, 0); // 稍微突出
            groove.receiveShadow = false;
            vinylGroup.add(groove);
        }

        // 唱片中心孔
        const holeGeo = new THREE.CylinderGeometry(0.2, 0.2, 0.3, 16);
        const holeMat = new THREE.MeshStandardMaterial({ color: 0x444444 });
        const hole = new THREE.Mesh(holeGeo, holeMat);
        hole.position.set(0, 0, 0);
        vinylGroup.add(hole);

        vinylGroup.position.set(0, 0.8, 0);
        vinylGroup.rotation.x = Math.PI / 2; // 让唱片立起来？为了更像黑胶播放器，通常平躺，但我们稍微倾斜使其更有立体感。这里选择稍微倾斜。
        vinylGroup.rotation.z = 0.3;
        vinylGroup.rotation.x = 0.2; 
        scene.add(vinylGroup);

        // --- 唱臂 (增加机械感) ---
        const armGroup = new THREE.Group();
        // 底座
        const baseArmGeo = new THREE.BoxGeometry(0.4, 0.2, 0.4);
        const baseArmMat = new THREE.MeshStandardMaterial({ color: 0xcccccc, metalness: 0.8, roughness: 0.2 });
        const baseArm = new THREE.Mesh(baseArmGeo, baseArmMat);
        baseArm.position.set(1.8, 0.3, 1.2);
        baseArm.castShadow = true;
        baseArm.receiveShadow = true;
        armGroup.add(baseArm);
        
        // 长杆
        const rodGeo = new THREE.BoxGeometry(0.1, 0.1, 2.0);
        const rodMat = new THREE.MeshStandardMaterial({ color: 0xeeeeee, metalness: 0.9, roughness: 0.1 });
        const rod = new THREE.Mesh(rodGeo, rodMat);
        rod.position.set(1.8, 0.5, 0.2);
        rod.rotation.x = 0.2;
        rod.rotation.z = -0.1;
        rod.castShadow = true;
        armGroup.add(rod);

        // 唱头
        const headGeo = new THREE.SphereGeometry(0.2, 16);
        const headMat = new THREE.MeshStandardMaterial({ color: 0xff6600, emissive: 0x331100 });
        const head = new THREE.Mesh(headGeo, headMat);
        head.position.set(1.8, 0.6, -0.7);
        head.castShadow = true;
        armGroup.add(head);

        scene.add(armGroup);

        // --- 浮空UI面板 (使用CSS2DRenderer模拟Vision Pro玻璃面板) ---
        function createPanel(text, subtext, x, y, z, width = 200) {
            const div = document.createElement('div');
            div.style.backgroundColor = 'rgba(30, 40, 60, 0.35)';
            div.style.backdropFilter = 'blur(20px)';
            div.style.borderRadius = '30px';
            div.style.padding = '16px 24px';
            div.style.border = '1px solid rgba(255, 255, 255, 0.25)';
            div.style.boxShadow = '0 20px 40px rgba(0,0,0,0.4), 0 0 0 1px rgba(255,255,255,0.1) inset';
            div.style.color = 'white';
            div.style.fontFamily = 'SF Pro Display, -apple-system, BlinkMacSystemFont, sans-serif';
            div.style.textAlign = 'center';
            div.style.width = width + 'px';
            div.style.backdropFilter = 'blur(25px)';
            div.style.webkitBackdropFilter = 'blur(25px)';
            
            const title = document.createElement('div');
            title.style.fontSize = '28px';
            title.style.fontWeight = '600';
            title.style.letterSpacing = '1px';
            title.style.marginBottom = '4px';
            title.style.textShadow = '0 2px 10px rgba(0,0,0,0.3)';
            title.innerText = text;
            
            const sub = document.createElement('div');
            sub.style.fontSize = '16px';
            sub.style.opacity = '0.8';
            sub.style.fontWeight = '400';
            sub.style.letterSpacing = '0.5px';
            sub.innerText = subtext;
            
            div.appendChild(title);
            div.appendChild(sub);
            
            const label = new CSS2DObject(div);
            label.position.set(x, y, z);
            return label;
        }

        // 添加三个主要控制面板
        const panel1 = createPanel('音频播放器', 'VISION AUDIO PRO', -2.5, 1.8, 1.2, 240);
        const panel2 = createPanel('现在播放', '月之暗面 · 轨道 3', 2.8, 2.0, -1.0, 200);
        const panel3 = createPanel('控制', '⏮  ⏸  ⏭', 0, 2.5, 2.5, 280);
        
        scene.add(panel1);
        scene.add(panel2);
        scene.add(panel3);

        // 添加小的标签 - 模拟均衡器或音量
        const eqDiv = document.createElement('div');
        eqDiv.style.color = 'white';
        eqDiv.style.background = 'rgba(0,0,0,0.4)';
        eqDiv.style.backdropFilter = 'blur(10px)';
        eqDiv.style.borderRadius = '40px';
        eqDiv.style.padding = '8px 18px';
        eqDiv.style.border = '1px solid rgba(255,180,60,0.6)';
        eqDiv.style.fontSize = '18px';
        eqDiv.style.fontWeight = '500';
        eqDiv.innerText = '🎧 空间音频';
        const eqLabel = new CSS2DObject(eqDiv);
        eqLabel.position.set(-1.0, 1.2, -2.2);
        scene.add(eqLabel);

        // --- 可视化音柱 (3D立体条，模拟音频反应) ---
        const barsGroup = new THREE.Group();
        const barCount = 16;
        const barSpacing = 0.25;
        const startX = - (barCount - 1) * barSpacing / 2;
        
        // 存储条以便动画
        const bars = [];
        
        for (let i = 0; i < barCount; i++) {
            // 每个条是一个小长方体
            const height = 0.3 + Math.random() * 0.8; // 随机初始高度
            const geo = new THREE.BoxGeometry(0.15, height, 0.15);
            const mat = new THREE.MeshStandardMaterial({
                color: new THREE.Color().setHSL(0.6 + i * 0.02, 1, 0.5),
                emissive: new THREE.Color().setHSL(0.6 + i * 0.02, 1, 0.1),
                transparent: true,
                opacity: 0.9
            });
            const bar = new THREE.Mesh(geo, mat);
            bar.castShadow = true;
            bar.receiveShadow = true;
            
            const xPos = startX + i * barSpacing;
            bar.position.set(xPos, height/2 + 0.1, -1.8); // 放在唱片后方作为背景装饰
            
            barsGroup.add(bar);
            
            // 保存原始高度和位置用于动画
            bars.push({
                mesh: bar,
                baseHeight: height,
                speed: 0.5 + Math.random() * 2,
                phase: Math.random() * Math.PI * 2,
                xPos: xPos
            });
        }
        scene.add(barsGroup);

        // 在音柱下方加一个细长玻璃条
        const barBaseGeo = new THREE.BoxGeometry(barCount * barSpacing + 0.3, 0.05, 0.4);
        const barBaseMat = new THREE.MeshPhysicalMaterial({ color: 0x88aaff, transparent: true, opacity: 0.2, metalness: 0.2, roughness: 0.1 });
        const barBase = new THREE.Mesh(barBaseGeo, barBaseMat);
        barBase.position.set(0, 0.02, -1.8);
        barBase.receiveShadow = true;
        scene.add(barBase);

        // 添加一些漂浮的小粒子围绕主体 (增加科技感)
        const particleCount = 40;
        const particleGeo = new THREE.SphereGeometry(0.05, 6);
        const particleMat = new THREE.MeshStandardMaterial({ color: 0x88aaff, emissive: 0x224466 });
        const particles = [];
        for (let i = 0; i < particleCount; i++) {
            const particle = new THREE.Mesh(particleGeo, particleMat.clone());
            const angle = (i / particleCount) * Math.PI * 2;
            const radius = 3.2 + Math.sin(i*2)*0.3;
            particle.position.set(
                Math.cos(angle) * radius,
                0.5 + Math.sin(i*3)*0.8,
                Math.sin(angle) * radius
            );
            particle.castShadow = true;
            scene.add(particle);
            particles.push({ mesh: particle, angle: angle, radius: radius, speed: 0.002 + Math.random()*0.003, offsetY: Math.random()*5 });
        }

        // --- 动画变量 ---
        let clock = new THREE.Clock();

        // --- 主动画循环 ---
        function animate() {
            const delta = clock.getDelta();
            const elapsedTime = performance.now() / 1000; // seconds

            // 更新自动旋转
            controls.update();

            // 唱片缓慢旋转
            vinylGroup.rotation.y += 0.002;
            
            // 唱臂微微摆动 (模拟真实唱臂)
            armGroup.rotation.z = Math.sin(elapsedTime * 0.5) * 0.02;
            
            // 音柱动画 (模拟音频可视化)
            bars.forEach(barData => {
                // 利用正弦波制造动态高度
                const dynamicHeight = barData.baseHeight + Math.sin(elapsedTime * barData.speed * 3 + barData.phase) * 0.3 + 0.2;
                const h = Math.max(0.1, dynamicHeight);
                barData.mesh.scale.y = h / barData.baseHeight; // 改变y轴缩放而不是重新创建geometry
                barData.mesh.position.y = h / 2 + 0.1; // 保持底部固定
                
                // 颜色微变
                const hue = (0.6 + barData.xPos * 0.1 + elapsedTime * 0.05) % 1.0;
                barData.mesh.material.color.setHSL(hue, 1, 0.6);
            });

            // 粒子绕中心旋转
            particles.forEach(p => {
                p.angle += p.speed * 30 * delta;
                p.mesh.position.x = Math.cos(p.angle) * p.radius;
                p.mesh.position.z = Math.sin(p.angle) * p.radius;
                // 上下浮动
                p.mesh.position.y = 0.8 + Math.sin(elapsedTime * 2 + p.offsetY) * 0.5;
            });

            // 星星缓慢旋转
            stars.rotation.y += 0.0001;

            // 渲染主场景
            renderer.render(scene, camera);
            
            // 渲染CSS标签 (必须单独调用)
            labelRenderer.render(scene, camera);

            requestAnimationFrame(animate);
        }

        animate();

        // --- 窗口大小自适应 ---
        window.addEventListener('resize', onWindowResize, false);
        function onWindowResize() {
            camera.aspect = window.innerWidth / window.innerHeight;
            camera.updateProjectionMatrix();
            renderer.setSize(window.innerWidth, window.innerHeight);
            labelRenderer.setSize(window.innerWidth, window.innerHeight);
        }

        // 可选: 添加一个简单的射线或光晕 (后期效果可通过额外pass，但为了简洁省略)
        console.log('Vision Audio Pro 3D UI 已启动');
    </script>
</body>
</html>