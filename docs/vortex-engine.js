/**
 * 3-6-9 Vortex Mathematics Engine
 * Modern ES2024 implementation of Tesla's digital root algorithms
 * with advanced computer science optimization techniques
 */

class VortexMathEngine {
    constructor() {
        this.iterationCount = 0;
        this.currentRoot = 9;
        this.vortexState = 'Harmonic';
        this.patterns = [];
        this.isRunning = false;
        this.maxIterations = 369; // Tesla's sacred number
        
        this.initializeElements();
        this.loadPatterns();
        this.setupEventListeners();
        this.initializeVortexGrid();
    }

    initializeElements() {
        this.elements = {
            grid: document.getElementById('vortexGrid'),
            patterns: document.getElementById('vortexPatterns'),
            iterateBtn: document.getElementById('vortexIterate'),
            resetBtn: document.getElementById('vortexReset'),
            searchInput: document.getElementById('vortexSearch'),
            stats: document.getElementById('vortexStats'),
            digitalRoot: document.getElementById('digitalRoot'),
            currentStep: document.getElementById('currentStep'),
            progressBar: document.getElementById('progressBar'),
            iterationCount: document.getElementById('iterationCount'),
            currentRoot: document.getElementById('currentRoot'),
            vortexState: document.getElementById('vortexState')
        };
    }

    async loadPatterns() {
        try {
            const response = await fetch('./notes/index.json');
            this.patterns = await response.json();
            this.renderPatterns();
            this.updateStats();
        } catch (error) {
            console.error('Failed to load patterns:', error);
            this.patterns = [];
        }
    }

    setupEventListeners() {
        this.elements.iterateBtn.addEventListener('click', () => this.startVortexIteration());
        this.elements.resetBtn.addEventListener('click', () => this.resetVortex());
        this.elements.searchInput.addEventListener('input', (e) => this.filterPatterns(e.target.value));
    }

    /**
     * Digital Root Algorithm - Core of 3-6-9 mathematics
     * Implements Tesla's digital root calculation with optimization
     */
    calculateDigitalRoot(number) {
        if (number === 0) return 0;
        if (number === 9) return 9;
        
        // Optimized digital root calculation
        const root = number % 9;
        return root === 0 ? 9 : root;
    }

    /**
     * Vortex Pattern Generator
     * Creates mathematical patterns based on 3-6-9 principles
     */
    generateVortexPattern(iteration) {
        const patterns = [
            { cols: 27, cellSize: '1rem', gap: '0.25rem', radius: '0.25rem' }, // 3×9
            { cols: 18, cellSize: '0.75rem', gap: '0.125rem', radius: '0.125rem' }, // 3×6
            { cols: 36, cellSize: '1.25rem', gap: '0.375rem', radius: '0.375rem' }, // 3×12
            { cols: 45, cellSize: '1.5rem', gap: '0.5rem', radius: '0.5rem' }, // 3×15
            { cols: 54, cellSize: '0.875rem', gap: '0.1875rem', radius: '0.1875rem' }, // 3×18
            { cols: 63, cellSize: '1.125rem', gap: '0.3125rem', radius: '0.3125rem' } // 3×21
        ];
        
        const patternIndex = iteration % patterns.length;
        return patterns[patternIndex];
    }

    /**
     * Advanced Vortex Grid Generation
     * Creates optimized grid with 3-6-9 mathematical properties
     */
    generateVortexGrid(pattern) {
        const { cols, cellSize, gap, radius } = pattern;
        const rows = 9; // Always 9 rows for 3-6-9 symmetry
        
        // Update CSS custom properties
        document.documentElement.style.setProperty('--grid-cols', cols);
        document.documentElement.style.setProperty('--grid-cell-size', cellSize);
        document.documentElement.style.setProperty('--grid-gap', gap);
        document.documentElement.style.setProperty('--grid-radius', radius);
        
        // Clear existing grid
        this.elements.grid.innerHTML = '';
        
        // Generate cells with 3-6-9 pattern
        for (let r = 0; r < rows; r++) {
            for (let c = 0; c < cols; c++) {
                const cell = this.createVortexCell(r, c, cols);
                this.elements.grid.appendChild(cell);
            }
        }
    }

    createVortexCell(row, col, totalCols) {
        const cell = document.createElement('div');
        cell.className = 'vortex-cell';
        
        // Calculate value based on 3-6-9 vortex mathematics
        const position = (row * totalCols + col) % 9;
        const value = this.calculateVortexValue(position, row, col);
        
        cell.setAttribute('data-value', value);
        cell.setAttribute('data-row', row);
        cell.setAttribute('data-col', col);
        cell.setAttribute('data-position', position);
        
        // Add hover effects
        cell.addEventListener('mouseenter', () => this.highlightVortexPath(cell));
        cell.addEventListener('click', () => this.activateVortexCell(cell));
        
        return cell;
    }

    calculateVortexValue(position, row, col) {
        // Advanced 3-6-9 calculation using multiple algorithms
        const fibonacci = this.fibonacci(position + 1);
        const digitalRoot = this.calculateDigitalRoot(fibonacci);
        
        // Apply vortex mathematics
        if (digitalRoot === 3 || digitalRoot === 6 || digitalRoot === 9) {
            return digitalRoot;
        }
        
        // Fallback to position-based calculation
        const baseValue = (position + 1) % 9;
        return baseValue === 0 ? 9 : baseValue;
    }

    fibonacci(n) {
        if (n <= 1) return n;
        let a = 0, b = 1;
        for (let i = 2; i <= n; i++) {
            [a, b] = [b, a + b];
        }
        return b;
    }

    highlightVortexPath(cell) {
        const value = parseInt(cell.dataset.value);
        const cells = this.elements.grid.querySelectorAll('.vortex-cell');
        
        // Reset all cells
        cells.forEach(c => c.classList.remove('vortex-highlight'));
        
        // Highlight cells with same value
        cells.forEach(c => {
            if (parseInt(c.dataset.value) === value) {
                c.classList.add('vortex-highlight');
            }
        });
    }

    activateVortexCell(cell) {
        const value = parseInt(cell.dataset.value);
        this.currentRoot = value;
        this.updateDigitalRoot();
        this.updateMetrics();
        
        // Add activation effect
        cell.classList.add('vortex-activated');
        setTimeout(() => cell.classList.remove('vortex-activated'), 1000);
    }

    /**
     * Main Vortex Iteration Loop
     * Implements the core 3-6-9 algorithm with modern optimization
     */
    async startVortexIteration() {
        if (this.isRunning) return;
        
        this.isRunning = true;
        this.elements.iterateBtn.disabled = true;
        this.elements.iterateBtn.textContent = '⚡ Iterating...';
        
        try {
            await this.executeVortexLoop();
        } catch (error) {
            console.error('Vortex iteration error:', error);
        } finally {
            this.isRunning = false;
            this.elements.iterateBtn.disabled = false;
            this.elements.iterateBtn.innerHTML = '<span class="btn-icon">⚡</span><span class="btn-text">Iterate Vortex</span>';
        }
    }

    async executeVortexLoop() {
        const startTime = performance.now();
        
        for (let i = 0; i < this.maxIterations; i++) {
            // Update iteration count
            this.iterationCount = i + 1;
            
            // Calculate current digital root
            this.currentRoot = this.calculateDigitalRoot(this.iterationCount);
            
            // Update vortex state based on mathematical properties
            this.updateVortexState();
            
            // Generate new pattern every 9 iterations (3×3)
            if (i % 9 === 0) {
                const pattern = this.generateVortexPattern(i);
                this.generateVortexGrid(pattern);
            }
            
            // Update UI
            this.updateProgress();
            this.updateMetrics();
            this.updateDigitalRoot();
            
            // Add delay for visual effect (respects reduced motion preference)
            if (!window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
                await this.delay(50);
            }
            
            // Check for completion conditions
            if (this.checkVortexCompletion()) {
                break;
            }
        }
        
        const endTime = performance.now();
        console.log(`Vortex iteration completed in ${endTime - startTime}ms`);
        
        this.elements.currentStep.textContent = 'Vortex Mathematics Complete';
        this.elements.progressBar.style.width = '100%';
    }

    updateVortexState() {
        const states = ['Harmonic', 'Resonant', 'Convergent', 'Divergent', 'Stable', 'Dynamic'];
        const stateIndex = this.iterationCount % states.length;
        this.vortexState = states[stateIndex];
    }

    checkVortexCompletion() {
        // Complete when we reach 369 iterations or achieve perfect 3-6-9 harmony
        return this.iterationCount >= this.maxIterations || 
               (this.currentRoot === 9 && this.iterationCount % 9 === 0);
    }

    updateProgress() {
        const progress = (this.iterationCount / this.maxIterations) * 100;
        this.elements.progressBar.style.width = `${progress}%`;
        this.elements.currentStep.textContent = `Iteration ${this.iterationCount}: Digital Root ${this.currentRoot}`;
    }

    updateMetrics() {
        this.elements.iterationCount.textContent = this.iterationCount;
        this.elements.currentRoot.textContent = this.currentRoot;
        this.elements.vortexState.textContent = this.vortexState;
    }

    updateDigitalRoot() {
        this.elements.digitalRoot.textContent = this.currentRoot;
        this.elements.digitalRoot.style.color = this.getVortexColor(this.currentRoot);
    }

    getVortexColor(value) {
        const colors = {
            3: 'var(--vortex-3)',
            6: 'var(--vortex-6)',
            9: 'var(--vortex-9)'
        };
        return colors[value] || 'var(--vortex-accent)';
    }

    resetVortex() {
        this.iterationCount = 0;
        this.currentRoot = 9;
        this.vortexState = 'Harmonic';
        this.isRunning = false;
        
        // Reset UI
        this.elements.progressBar.style.width = '0%';
        this.elements.currentStep.textContent = 'Ready to begin vortex iteration';
        this.updateMetrics();
        this.updateDigitalRoot();
        
        // Reset grid to initial state
        const initialPattern = this.generateVortexPattern(0);
        this.generateVortexGrid(initialPattern);
    }

    renderPatterns() {
        this.elements.patterns.innerHTML = '';
        
        this.patterns.forEach((pattern, index) => {
            const patternElement = this.createPatternElement(pattern, index);
            this.elements.patterns.appendChild(patternElement);
        });
    }

    createPatternElement(pattern, index) {
        const element = document.createElement('div');
        element.className = 'vortex-pattern';
        
        const dayMatch = pattern.title.match(/Day (\d+)/);
        const dayNumber = dayMatch ? dayMatch[1] : '0';
        
        element.innerHTML = `
            <div class="pattern-title">${pattern.title}</div>
            <div class="pattern-summary">${pattern.summary}</div>
            <div class="pattern-meta">
                <span class="pattern-day">Day ${dayNumber}</span>
                <span>Pattern ${index + 1}</span>
            </div>
        `;
        
        element.addEventListener('click', () => this.openPattern(pattern, dayNumber));
        
        return element;
    }

    openPattern(pattern, dayNumber) {
        const slug = `d${dayNumber}-c1`;
        window.open(`./notes/${slug}/index.md`, '_blank');
    }

    filterPatterns(query) {
        const filtered = this.patterns.filter(pattern =>
            pattern.title.toLowerCase().includes(query.toLowerCase()) ||
            pattern.summary.toLowerCase().includes(query.toLowerCase())
        );
        
        this.elements.patterns.innerHTML = '';
        filtered.forEach((pattern, index) => {
            const patternElement = this.createPatternElement(pattern, index);
            this.elements.patterns.appendChild(patternElement);
        });
        
        this.elements.stats.textContent = `${filtered.length} of ${this.patterns.length} patterns`;
    }

    updateStats() {
        this.elements.stats.textContent = `${this.patterns.length} patterns`;
    }

    initializeVortexGrid() {
        const initialPattern = this.generateVortexPattern(0);
        this.generateVortexGrid(initialPattern);
    }

    delay(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }
}

// Initialize the Vortex Mathematics Engine
document.addEventListener('DOMContentLoaded', () => {
    window.vortexEngine = new VortexMathEngine();
});

// Export for module usage
export default VortexMathEngine;
