/* NEON TETHER - INTERACTIVE UX/UI PROTOTYPE ENGINE */

// --- AUDIO SYNTHESIZER ---
class CyberSynth {
    constructor() {
        this.ctx = null;
        this.enabled = true;
        this.bgmGain = null;
        this.bgmIntervalId = null;
        this.bgmStep = 0;
    }

    init() {
        if (this.ctx) return;
        this.ctx = new (window.AudioContext || window.webkitAudioContext)();
    }

    resume() {
        if (this.ctx && this.ctx.state === 'suspended') {
            this.ctx.resume();
        }
    }

    startBGM() {
        if (!this.enabled) return;
        this.init(); this.resume();
        if (this.bgmIntervalId) return; // already running

        this.bgmGain = this.ctx.createGain();
        this.bgmGain.gain.value = 0.05;
        this.bgmGain.connect(this.ctx.destination);

        // Minor arpeggio loop (A minor pentatonic-ish) — ambient cyber pad
        const pattern = [220.00, 261.63, 329.63, 392.00, 329.63, 261.63];
        const stepMs = 260;

        const playStep = () => {
            if (!this.enabled || !this.ctx) return;
            const freq = pattern[this.bgmStep % pattern.length];
            this.bgmStep++;

            const osc = this.ctx.createOscillator();
            const filter = this.ctx.createBiquadFilter();
            const noteGain = this.ctx.createGain();

            osc.type = 'triangle';
            osc.frequency.setValueAtTime(freq, this.ctx.currentTime);
            filter.type = 'lowpass';
            filter.frequency.setValueAtTime(900, this.ctx.currentTime);

            noteGain.gain.setValueAtTime(0.0001, this.ctx.currentTime);
            noteGain.gain.linearRampToValueAtTime(1, this.ctx.currentTime + 0.03);
            noteGain.gain.exponentialRampToValueAtTime(0.0001, this.ctx.currentTime + (stepMs / 1000) * 0.9);

            osc.connect(filter);
            filter.connect(noteGain);
            noteGain.connect(this.bgmGain);

            osc.start();
            osc.stop(this.ctx.currentTime + stepMs / 1000);
        };

        playStep();
        this.bgmIntervalId = setInterval(playStep, stepMs);
    }

    stopBGM() {
        if (this.bgmIntervalId) {
            clearInterval(this.bgmIntervalId);
            this.bgmIntervalId = null;
        }
    }

    playSplit() {
        if (!this.enabled) return;
        this.init(); this.resume();
        const osc = this.ctx.createOscillator();
        const gain = this.ctx.createGain();
        osc.connect(gain);
        gain.connect(this.ctx.destination);

        osc.type = 'sawtooth';
        osc.frequency.setValueAtTime(150, this.ctx.currentTime);
        osc.frequency.exponentialRampToValueAtTime(600, this.ctx.currentTime + 0.15);

        gain.gain.setValueAtTime(0.08, this.ctx.currentTime);
        gain.gain.exponentialRampToValueAtTime(0.001, this.ctx.currentTime + 0.15);

        osc.start();
        osc.stop(this.ctx.currentTime + 0.16);
    }

    playMerge() {
        if (!this.enabled) return;
        this.init(); this.resume();
        // Play a nice synth chord (C4, G4, C5)
        const freqs = [130.81, 196.00, 261.63];
        const now = this.ctx.currentTime;

        freqs.forEach(freq => {
            const osc = this.ctx.createOscillator();
            const filter = this.ctx.createBiquadFilter();
            const gain = this.ctx.createGain();

            osc.connect(filter);
            filter.connect(gain);
            gain.connect(this.ctx.destination);

            osc.type = 'triangle';
            osc.frequency.setValueAtTime(freq, now);

            filter.type = 'lowpass';
            filter.frequency.setValueAtTime(1200, now);
            filter.frequency.exponentialRampToValueAtTime(100, now + 0.25);

            gain.gain.setValueAtTime(0.12, now);
            gain.gain.exponentialRampToValueAtTime(0.001, now + 0.25);

            osc.start();
            osc.stop(now + 0.26);
        });
    }

    playGraze() {
        if (!this.enabled) return;
        this.init(); this.resume();
        const osc = this.ctx.createOscillator();
        const gain = this.ctx.createGain();
        osc.connect(gain);
        gain.connect(this.ctx.destination);

        osc.type = 'sine';
        osc.frequency.setValueAtTime(1200, this.ctx.currentTime);
        osc.frequency.setValueAtTime(1500, this.ctx.currentTime + 0.05);

        gain.gain.setValueAtTime(0.06, this.ctx.currentTime);
        gain.gain.exponentialRampToValueAtTime(0.001, this.ctx.currentTime + 0.2);

        osc.start();
        osc.stop(this.ctx.currentTime + 0.22);
    }

    playCrash() {
        if (!this.enabled) return;
        this.init(); this.resume();
        const bufferSize = this.ctx.sampleRate * 0.4;
        const buffer = this.ctx.createBuffer(1, bufferSize, this.ctx.sampleRate);
        const data = buffer.getChannelData(0);
        for (let i = 0; i < bufferSize; i++) {
            data[i] = Math.random() * 2 - 1;
        }

        const noise = this.ctx.createBufferSource();
        noise.buffer = buffer;

        const filter = this.ctx.createBiquadFilter();
        filter.type = 'lowpass';
        filter.frequency.setValueAtTime(800, this.ctx.currentTime);
        filter.frequency.exponentialRampToValueAtTime(50, this.ctx.currentTime + 0.35);

        const gain = this.ctx.createGain();
        gain.gain.setValueAtTime(0.18, this.ctx.currentTime);
        gain.gain.exponentialRampToValueAtTime(0.001, this.ctx.currentTime + 0.38);

        noise.connect(filter);
        filter.connect(gain);
        gain.connect(this.ctx.destination);

        noise.start();
        noise.stop(this.ctx.currentTime + 0.4);
    }
}

const synth = new CyberSynth();

// --- STATE MANAGEMENT ---
const state = {
    currentScreen: 'screen-splash',
    crystals: 1240,
    bestScore: 2450,
    score: 0,
    combo: 1.0,
    runCrystals: 0,
    activeTether: 'default',
    activeCore: 'core-default',
    ownedItems: ['default', 'core-default'],
    runHistory: [],
    colorblind: 'none',
    musicEnabled: true,
    hapticsEnabled: true,
    gameplay: {
        active: false,
        width: 10,       // current tether separation in px
        targetWidth: 10, // target tether separation (10 for merge, 140 for split)
        obstacles: [],
        crystalsList: [],
        speed: 6,
        nextObstacleTime: 0,
        keys: {}
    },
    tutorial: {
        step: 1,
        width: 10,
        targetWidth: 10,
        holding: false
    }
};

// --- DOM CACHE ---
const dom = {
    screens: document.querySelectorAll('.screen'),
    menuCrystalCount: document.getElementById('menu-crystal-count'),
    shopCrystalCounts: document.querySelectorAll('.shop-crystal-count'),
    hudScore: document.getElementById('hud-score'),
    hudCrystals: document.getElementById('hud-crystals'),
    hudComboContainer: document.getElementById('hud-combo-container'),
    hudComboMultiplier: document.getElementById('hud-combo-multiplier'),
    sphereLeft: document.getElementById('sphere-left'),
    sphereRight: document.getElementById('sphere-right'),
    tetherLine: document.getElementById('player-tether-line'),
    gameCanvas: document.getElementById('game-canvas-area'),
    overlayPause: document.getElementById('overlay-pause'),
    goDistance: document.getElementById('go-distance'),
    goBestDistance: document.getElementById('go-best-distance'),
    goCrystals: document.getElementById('go-crystals'),
    shopItems: document.querySelectorAll('.shop-item'),
    shopTabs: document.querySelectorAll('.shop-tab'),
    shopGrids: document.querySelectorAll('.shop-grid'),
    tutSphereLeft: document.getElementById('tut-sphere-left'),
    tutSphereRight: document.getElementById('tut-sphere-right'),
    tutTetherLine: document.getElementById('tutorial-tether-line'),
    tutorialCanvas: document.getElementById('tutorial-canvas'),
    tutInstruction: document.getElementById('tutorial-instruction'),
    tutHand: document.getElementById('tut-hand-indicator'),
    appContainer: document.getElementById('app-container'),
    leaderboardList: document.getElementById('leaderboard-list')
};

// --- LEADERBOARD (local, driven by real run history) ---
function renderLeaderboard() {
    const npcScores = [
        { name: 'MATRIX_CRASHER', score: 4890 },
        { name: 'CYBER_PULSE', score: 4120 },
        { name: 'TETHER_GOD', score: 3980 }
    ];
    const combined = npcScores.map(n => ({ ...n, isPlayer: false }));
    combined.push({ name: 'PILOT_01 (YOU)', score: state.bestScore, isPlayer: true });
    combined.sort((a, b) => b.score - a.score);

    dom.leaderboardList.innerHTML = '';
    combined.forEach((entry, idx) => {
        const rank = idx + 1;
        const row = document.createElement('div');
        row.className = 'leader-row' + (entry.isPlayer ? ' player-row' : ` rank-${rank}`);
        row.innerHTML = `<span class="rank">#${rank}</span><span class="player">${entry.name}</span><span class="score">${entry.score.toLocaleString()}m</span>`;
        dom.leaderboardList.appendChild(row);
    });
}

// --- NAVIGATION SYSTEM ---
function showScreen(screenId) {
    synth.init();
    dom.screens.forEach(screen => {
        if (screen.id === screenId) {
            screen.classList.add('active');
        } else {
            screen.classList.remove('active');
        }
    });
    state.currentScreen = screenId;

    if (screenId === 'screen-gameplay') {
        startGame();
    } else {
        stopGame();
    }

    if (screenId === 'screen-tutorial') {
        startTutorial();
    } else {
        stopTutorial();
    }
}

// Attach back buttons
document.querySelectorAll('.btn-back-to-menu').forEach(btn => {
    btn.addEventListener('click', () => showScreen('screen-menu'));
});

// Splash loading timeout
setTimeout(() => {
    showScreen('screen-menu');
    synth.startBGM();
}, 3000);

// Menu buttons
document.getElementById('btn-play-game').addEventListener('click', () => showScreen('screen-gameplay'));
document.getElementById('btn-open-tutorial').addEventListener('click', () => showScreen('screen-tutorial'));
document.getElementById('btn-nav-shop').addEventListener('click', () => showScreen('screen-shop'));
document.getElementById('btn-nav-achievements').addEventListener('click', () => showScreen('screen-achievements'));
document.getElementById('btn-nav-events').addEventListener('click', () => showScreen('screen-events'));
document.getElementById('btn-nav-settings').addEventListener('click', () => showScreen('screen-settings'));

// Pause overlay controls
document.getElementById('btn-pause-game').addEventListener('click', () => {
    state.gameplay.active = false;
    dom.overlayPause.classList.add('active');
});
document.getElementById('btn-resume').addEventListener('click', () => {
    state.gameplay.active = true;
    dom.overlayPause.classList.remove('active');
    gameLoop();
});
document.getElementById('btn-restart').addEventListener('click', () => {
    dom.overlayPause.classList.remove('active');
    startGame();
});
document.getElementById('btn-pause-menu').addEventListener('click', () => {
    dom.overlayPause.classList.remove('active');
    showScreen('screen-menu');
});

// Game over screen controls
document.getElementById('btn-retry').addEventListener('click', () => showScreen('screen-gameplay'));
document.getElementById('btn-gameover-menu').addEventListener('click', () => showScreen('screen-menu'));
document.getElementById('btn-rewarded-continue').addEventListener('click', () => {
    // Simulate watching a rewarded ad, then continue once
    document.getElementById('btn-rewarded-continue').style.display = 'none';
    showScreen('screen-gameplay');
});

// Shop items selection and buying
dom.shopItems.forEach(item => {
    item.addEventListener('click', () => {
        const id = item.dataset.id;
        const price = item.dataset.price;
        const isTether = item.parentElement.id.includes('tethers');
        const isCore = item.parentElement.id.includes('cores');

        if (item.classList.contains('owned')) {
            // Select item
            if (isTether) {
                state.activeTether = id;
                document.querySelectorAll('#shop-content-tethers .shop-item').forEach(i => i.classList.remove('selected'));
            } else if (isCore) {
                state.activeCore = id;
                document.querySelectorAll('#shop-content-cores .shop-item').forEach(i => i.classList.remove('selected'));
            }
            item.classList.add('selected');
            applySkinStyles();
            saveProgress();
        } else {
            // Buy item simulation
            const parsedPrice = parseFloat(price);
            if (price.startsWith('$')) {
                // IAP buying trigger
                alert(`Redirecting to App Store for security payment of ${price}... Purchase successful!`);
                item.classList.add('owned', 'selected');
                if (!state.ownedItems.includes(id)) state.ownedItems.push(id);
                if (isTether) {
                    state.activeTether = id;
                    document.querySelectorAll('#shop-content-tethers .shop-item').forEach(i => i.classList.remove('selected'));
                } else if (isCore) {
                    state.activeCore = id;
                    document.querySelectorAll('#shop-content-cores .shop-item').forEach(i => i.classList.remove('selected'));
                }
                item.classList.add('selected');
                applySkinStyles();
                saveProgress();
            } else if (state.crystals >= parsedPrice) {
                state.crystals -= parsedPrice;
                updateCrystalsUI();
                item.classList.add('owned', 'selected');
                item.querySelector('.item-price').textContent = "ACTIVE";
                if (!state.ownedItems.includes(id)) state.ownedItems.push(id);
                if (isTether) {
                    state.activeTether = id;
                    document.querySelectorAll('#shop-content-tethers .shop-item').forEach(i => i.classList.remove('selected'));
                } else if (isCore) {
                    state.activeCore = id;
                    document.querySelectorAll('#shop-content-cores .shop-item').forEach(i => i.classList.remove('selected'));
                }
                item.classList.add('selected');
                applySkinStyles();
                saveProgress();
            } else {
                alert("INSUFFICIENT VOLT CRYSTALS!");
            }
        }
    });
});

// Shop tabs switcher
dom.shopTabs.forEach(tab => {
    tab.addEventListener('click', () => {
        dom.shopTabs.forEach(t => t.classList.remove('active'));
        tab.classList.add('active');

        const targetGridId = 'shop-content-' + tab.id.replace('tab-', '');
        dom.shopGrids.forEach(grid => {
            if (grid.id === targetGridId) {
                grid.classList.add('active');
            } else {
                grid.classList.remove('active');
            }
        });
    });
});

// Settings controllers
document.getElementById('setting-music').addEventListener('change', (e) => {
    state.musicEnabled = e.target.checked;
    synth.enabled = state.musicEnabled;
    if (state.musicEnabled) {
        synth.startBGM();
    } else {
        synth.stopBGM();
    }
    saveProgress();
});
document.getElementById('setting-haptics').addEventListener('change', (e) => {
    state.hapticsEnabled = e.target.checked;
    saveProgress();
});
document.getElementById('setting-colorblind').addEventListener('change', (e) => {
    state.colorblind = e.target.value;
    applyColorblindStyles();
    saveProgress();
});

// Apply styles
function hexToRgb(hex) {
    const clean = hex.replace('#', '');
    const bigint = parseInt(clean, 16);
    return { r: (bigint >> 16) & 255, g: (bigint >> 8) & 255, b: bigint & 255 };
}

function setNeonColors(cyanHex, magentaHex) {
    const container = dom.appContainer;
    const cyanRgb = hexToRgb(cyanHex);
    const magentaRgb = hexToRgb(magentaHex);
    container.style.setProperty('--neon-cyan', cyanHex);
    container.style.setProperty('--neon-magenta', magentaHex);
    // Glows are static rgba() values in :root, not derived from --neon-cyan/magenta —
    // without this they'd stay the original hue under colorblind modes or tether skins.
    container.style.setProperty('--glow-cyan', `0 0 15px rgba(${cyanRgb.r}, ${cyanRgb.g}, ${cyanRgb.b}, 0.6), 0 0 30px rgba(${cyanRgb.r}, ${cyanRgb.g}, ${cyanRgb.b}, 0.3)`);
    container.style.setProperty('--glow-magenta', `0 0 15px rgba(${magentaRgb.r}, ${magentaRgb.g}, ${magentaRgb.b}, 0.6), 0 0 30px rgba(${magentaRgb.r}, ${magentaRgb.g}, ${magentaRgb.b}, 0.3)`);
}

function applySkinStyles() {
    // Dynamic styles depending on skin selected
    const container = dom.appContainer;
    container.className = '';

    if (state.colorblind !== 'none') {
        applyColorblindStyles();
        return;
    }

    if (state.activeTether === 'laser') {
        setNeonColors('#00f0ff', '#ff003c');
        container.style.setProperty('--tether-width', '4px');
    } else if (state.activeTether === 'plasma') {
        setNeonColors('#00ffaa', '#ff007f');
        container.style.setProperty('--tether-width', '3px');
    } else if (state.activeTether === 'rainbow') {
        setNeonColors('#ff00ff', '#00ffff');
        container.style.setProperty('--tether-width', '2px');
    } else {
        setNeonColors('#00f0ff', '#ff007f');
        container.style.setProperty('--tether-width', '2px');
    }
}

function applyColorblindStyles() {
    if (state.colorblind === 'protan') {
        setNeonColors('#0055ff', '#ffaa00');
    } else if (state.colorblind === 'deuteran') {
        setNeonColors('#00aaff', '#ffdd00');
    } else {
        applySkinStyles();
    }
}

function updateCrystalsUI() {
    dom.menuCrystalCount.textContent = state.crystals.toLocaleString();
    dom.shopCrystalCounts.forEach(el => el.textContent = state.crystals.toLocaleString());
}

// --- LOCAL PERSISTENCE (localStorage) ---
const SAVE_KEY = 'neonTetherSave';

function saveProgress() {
    const payload = {
        crystals: state.crystals,
        bestScore: state.bestScore,
        activeTether: state.activeTether,
        activeCore: state.activeCore,
        ownedItems: state.ownedItems,
        runHistory: state.runHistory,
        colorblind: state.colorblind,
        musicEnabled: state.musicEnabled,
        hapticsEnabled: state.hapticsEnabled
    };
    try {
        localStorage.setItem(SAVE_KEY, JSON.stringify(payload));
    } catch (err) {
        // Storage unavailable (private mode, quota) — fail silently, progress stays in-memory only.
    }
}

function loadProgress() {
    let saved = null;
    try {
        const raw = localStorage.getItem(SAVE_KEY);
        if (raw) saved = JSON.parse(raw);
    } catch (err) {
        saved = null;
    }
    if (!saved) return;

    state.crystals = typeof saved.crystals === 'number' ? saved.crystals : state.crystals;
    state.bestScore = typeof saved.bestScore === 'number' ? saved.bestScore : state.bestScore;
    state.activeTether = saved.activeTether || state.activeTether;
    state.activeCore = saved.activeCore || state.activeCore;
    state.ownedItems = Array.isArray(saved.ownedItems) ? saved.ownedItems : state.ownedItems;
    state.runHistory = Array.isArray(saved.runHistory) ? saved.runHistory : state.runHistory;
    state.colorblind = saved.colorblind || state.colorblind;
    state.musicEnabled = typeof saved.musicEnabled === 'boolean' ? saved.musicEnabled : state.musicEnabled;
    state.hapticsEnabled = typeof saved.hapticsEnabled === 'boolean' ? saved.hapticsEnabled : state.hapticsEnabled;

    updateCrystalsUI();

    // Re-apply ownership/selection to the shop DOM
    dom.shopItems.forEach(item => {
        const id = item.dataset.id;
        if (state.ownedItems.includes(id)) {
            item.classList.add('owned');
            const priceEl = item.querySelector('.item-price');
            if (priceEl) priceEl.textContent = 'ACTIVE';
        }
        if (id === state.activeTether || id === state.activeCore) {
            item.classList.add('selected');
        } else {
            item.classList.remove('selected');
        }
    });

    // Re-apply settings toggles
    document.getElementById('setting-music').checked = state.musicEnabled;
    document.getElementById('setting-haptics').checked = state.hapticsEnabled;
    document.getElementById('setting-colorblind').value = state.colorblind;
    synth.enabled = state.musicEnabled;

    applySkinStyles();
    applyColorblindStyles();
    renderLeaderboard();
}

// --- GAMEPLAY CODE ENGINE (SIMULATION) ---
let gameLoopId = null;

function startGame() {
    state.score = 0;
    state.runCrystals = 0;
    state.combo = 1.0;
    state.gameplay.speed = 5;
    state.gameplay.width = 10;
    state.gameplay.targetWidth = 10;
    state.gameplay.obstacles = [];
    state.gameplay.crystalsList = [];
    state.gameplay.active = true;
    state.gameplay.nextObstacleTime = 0;

    document.getElementById('btn-rewarded-continue').style.display = 'block';

    // Clear old visual DOM components
    document.querySelectorAll('.obstacle, .crystal-node').forEach(el => el.remove());

    dom.hudScore.textContent = '0m';
    dom.hudCrystals.textContent = '0';
    dom.hudComboContainer.classList.remove('active');

    // Attach Event Listeners for Game Controls
    dom.gameCanvas.addEventListener('pointerdown', handleTouchStart);
    dom.gameCanvas.addEventListener('pointerup', handleTouchEnd);

    gameLoop();
}

function stopGame() {
    state.gameplay.active = false;
    if (gameLoopId) {
        cancelAnimationFrame(gameLoopId);
        gameLoopId = null;
    }
    dom.gameCanvas.removeEventListener('pointerdown', handleTouchStart);
    dom.gameCanvas.removeEventListener('pointerup', handleTouchEnd);
}

function handleTouchStart(e) {
    e.preventDefault();
    state.gameplay.targetWidth = 140; // Max split width
    synth.playSplit();
    triggerHaptic(50);
}

function handleTouchEnd(e) {
    e.preventDefault();
    state.gameplay.targetWidth = 10; // Snap merge
    synth.playMerge();
    triggerHaptic(80);
}

function triggerHaptic(duration) {
    if (state.hapticsEnabled && navigator.vibrate) {
        navigator.vibrate(duration);
    }
}

function gameLoop() {
    if (!state.gameplay.active) return;

    // 1. Interpolate tether width (spring easing)
    const diff = state.gameplay.targetWidth - state.gameplay.width;
    state.gameplay.width += diff * 0.18; // Lerp speed

    // Update Spheres layout
    const offset = state.gameplay.width / 2;
    dom.sphereLeft.style.left = `calc(50% - ${offset}px)`;
    dom.sphereRight.style.left = `calc(50% + ${offset}px)`;
    dom.tetherLine.style.width = `${state.gameplay.width}px`;

    // 2. Generate procedural obstacles & crystals
    state.gameplay.nextObstacleTime -= 1;
    if (state.gameplay.nextObstacleTime <= 0) {
        spawnObstacleOrCrystal();
        state.gameplay.nextObstacleTime = 50 + Math.random() * 40; // Spacing logic
    }

    // 3. Move obstacles & check collision
    moveAndCollide();

    // 4. Score ticking
    state.score += 1;
    dom.hudScore.textContent = `${Math.floor(state.score / 5)}m`;

    gameLoopId = requestAnimationFrame(gameLoop);
}

function spawnObstacleOrCrystal() {
    const parent = dom.gameCanvas;
    const rng = Math.random();

    if (rng < 0.6) {
        // Spawn Obstacle
        const el = document.createElement('div');
        el.className = 'obstacle';
        
        const type = Math.random() < 0.5 ? 'center-pillar' : 'side-pillar';
        el.classList.add(type);
        el.style.top = '-50px';

        if (type === 'center-pillar') {
            el.style.left = '50%';
        } else {
            // Side barriers require twin nodes on boundaries
            el.style.width = '100px';
            // Alternates sides or does both
            el.style.left = Math.random() < 0.5 ? '10px' : 'calc(100% - 110px)';
            el.style.transform = 'translate(0, -50%)';
        }

        parent.appendChild(el);
        state.gameplay.obstacles.push({
            dom: el,
            type: type,
            y: -50,
            hit: false
        });
    } else {
        // Spawn Volt Crystal
        const el = document.createElement('div');
        el.className = 'crystal-node';
        el.style.top = '-50px';
        // Put crystals on left lane, center, or right lane
        const lR = Math.random();
        let leftPct = '50%';
        if (lR < 0.33) leftPct = 'calc(50% - 60px)';
        else if (lR > 0.66) leftPct = 'calc(50% + 60px)';
        
        el.style.left = leftPct;
        parent.appendChild(el);
        state.gameplay.crystalsList.push({
            dom: el,
            y: -50,
            leftPct: leftPct
        });
    }
}

function moveAndCollide() {
    const canvasHeight = dom.gameCanvas.clientHeight;
    
    // Player core hitbox positions (vertical location is absolute: bottom 180px, meaning Y = height - 180)
    const playerY = canvasHeight - 180;
    const sphereOffset = state.gameplay.width / 2;
    const playerLeftX = (dom.gameCanvas.clientWidth / 2) - sphereOffset;
    const playerRightX = (dom.gameCanvas.clientWidth / 2) + sphereOffset;

    // Move Obstacles
    for (let i = state.gameplay.obstacles.length - 1; i >= 0; i--) {
        const obs = state.gameplay.obstacles[i];
        obs.y += state.gameplay.speed;
        obs.dom.style.top = `${obs.y}px`;

        // Check Collision boundary
        if (!obs.hit && Math.abs(obs.y - playerY) < 22) {
            let collision = false;
            
            if (obs.type === 'center-pillar') {
                // Collides if player is merged (spheres too close to center)
                if (sphereOffset < 35) {
                    collision = true;
                }
            } else {
                // Side pillars: Collides if player is split (spheres hit the side obstacles)
                const obsLeft = parseFloat(obs.dom.style.left);
                if (obsLeft < 100) {
                    // Left obstacle
                    if (playerLeftX < 110) collision = true;
                } else {
                    // Right obstacle
                    if (playerRightX > (dom.gameCanvas.clientWidth - 110)) collision = true;
                }
            }

            if (collision) {
                obs.hit = true;
                handlePlayerCrash();
                return;
            } else {
                // Graze scoring (almost hit)
                triggerGraze();
            }
        }

        // Clean out screen obstacles
        if (obs.y > canvasHeight + 50) {
            obs.dom.remove();
            state.gameplay.obstacles.splice(i, 1);
        }
    }

    // Move & Collide Crystals
    for (let i = state.gameplay.crystalsList.length - 1; i >= 0; i--) {
        const cry = state.gameplay.crystalsList[i];
        cry.y += state.gameplay.speed;
        cry.dom.style.top = `${cry.y}px`;

        // Check collection distance
        const cryX = cry.dom.offsetLeft + 7;
        const distL = Math.hypot(cryX - playerLeftX, cry.y - playerY);
        const distR = Math.hypot(cryX - playerRightX, cry.y - playerY);

        if (distL < 25 || distR < 25) {
            // Collected!
            cry.dom.remove();
            state.gameplay.crystalsList.splice(i, 1);
            state.runCrystals += 1;
            state.crystals += 1;
            dom.hudCrystals.textContent = state.runCrystals;
            triggerHaptic(20);
        } else if (cry.y > canvasHeight + 50) {
            cry.dom.remove();
            state.gameplay.crystalsList.splice(i, 1);
        }
    }
}

function triggerGraze() {
    state.combo += 0.1;
    dom.hudComboMultiplier.textContent = `${state.combo.toFixed(1)}x`;
    dom.hudComboContainer.classList.add('active');
    synth.playGraze();
}

function handlePlayerCrash() {
    stopGame();
    synth.playCrash();
    triggerHaptic(200);

    // Apply screenshake style
    dom.appContainer.classList.add('screen-shake');
    setTimeout(() => dom.appContainer.classList.remove('screen-shake'), 400);

    // Update game over screen stats
    const dist = Math.floor(state.score / 5);
    if (dist > state.bestScore) {
        state.bestScore = dist;
    }

    state.runHistory.push(dist);
    if (state.runHistory.length > 20) state.runHistory.shift();

    dom.goDistance.textContent = `${dist}m`;
    dom.goBestDistance.textContent = `${state.bestScore}m`;
    dom.goCrystals.textContent = `+${state.runCrystals}`;

    updateCrystalsUI();
    saveProgress();
    renderLeaderboard();

    setTimeout(() => {
        showScreen('screen-gameover');
    }, 1000);
}

// --- INTERACTIVE TUTORIAL CODE ---
let tutLoopId = null;
function startTutorial() {
    state.tutorial.step = 1;
    state.tutorial.width = 10;
    state.tutorial.targetWidth = 10;
    state.tutorial.holding = false;

    dom.tutInstruction.textContent = "PRESS AND HOLD TO SPLIT CORE";
    dom.tutHand.style.display = 'block';

    dom.tutorialCanvas.addEventListener('pointerdown', handleTutStart);
    dom.tutorialCanvas.addEventListener('pointerup', handleTutEnd);

    tutorialLoop();
}

function stopTutorial() {
    if (tutLoopId) {
        cancelAnimationFrame(tutLoopId);
        tutLoopId = null;
    }
    dom.tutorialCanvas.removeEventListener('pointerdown', handleTutStart);
    dom.tutorialCanvas.removeEventListener('pointerup', handleTutEnd);
}

function handleTutStart(e) {
    e.preventDefault();
    state.tutorial.targetWidth = 140;
    state.tutorial.holding = true;
    synth.playSplit();
    
    if (state.tutorial.step === 1) {
        state.tutorial.step = 2;
        dom.tutInstruction.textContent = "RELEASE NOW TO MERGE SNAP";
    }
}

function handleTutEnd(e) {
    e.preventDefault();
    state.tutorial.targetWidth = 10;
    state.tutorial.holding = false;
    synth.playMerge();

    if (state.tutorial.step === 2) {
        state.tutorial.step = 3;
        dom.tutInstruction.textContent = "TUTORIAL SYSTEM OPERATIONAL!";
        dom.tutHand.style.display = 'none';
        
        setTimeout(() => {
            // Unlock first achievements
            alert("ACHIEVEMENT EARNED: First Transmission!");
            showScreen('screen-menu');
        }, 1500);
    }
}

function tutorialLoop() {
    const diff = state.tutorial.targetWidth - state.tutorial.width;
    state.tutorial.width += diff * 0.18;

    const offset = state.tutorial.width / 2;
    dom.tutSphereLeft.style.left = `calc(50% - ${offset}px)`;
    dom.tutSphereRight.style.left = `calc(50% + ${offset}px)`;
    dom.tutTetherLine.style.width = `${state.tutorial.width}px`;

    tutLoopId = requestAnimationFrame(tutorialLoop);
}

// Shake screen CSS class helper
const styleSheet = document.createElement("style");
styleSheet.innerText = `
.screen-shake {
    animation: shake 0.35s cubic-bezier(.36,.07,.19,.97) both;
    transform: translate3d(0, 0, 0);
}
@keyframes shake {
    10%, 90% { transform: translate3d(-2px, 0, 0); }
    20%, 80% { transform: translate3d(4px, 0, 0); }
    30%, 50%, 70% { transform: translate3d(-6px, 0, 0); }
    40%, 60% { transform: translate3d(6px, 0, 0); }
}
`;
document.head.appendChild(styleSheet);

// --- INIT: restore saved progress (crystals, skins, settings, run history) ---
renderLeaderboard();
loadProgress();
