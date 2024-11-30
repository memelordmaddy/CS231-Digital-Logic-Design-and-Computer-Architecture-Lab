import subprocess
import matplotlib.pyplot as plt

def run_dinero(cache_size, block_size, assoc, input_file):
    command = f"./dineroIV -l1-usize {cache_size}k -l1-ubsize {block_size} -l1-uassoc {assoc} -l1-uccc -l1-uwalloc a -l1-uwback a -informat d < ./{input_file}|grep -E \"Demand miss rate\""
    result = subprocess.run(command, shell=True, capture_output=True, text=True)
    output = result.stdout.split()
    print(output)
    return float(output[3]) if len(output) > 3 else 0

def analyze_cache_sizes(input_files):
    cache_sizes = [4, 8, 16, 32, 64, 128, 256, 512]
    results = {file: [] for file in input_files}

    for input_file in input_files:
        for size in cache_sizes:
            miss_rate = run_dinero(size, 16, 2, input_file)  
            results[input_file].append((size, miss_rate))

    return results, cache_sizes

def analyze_block_sizes(input_files):
    block_sizes = [1*4, 2*4, 4*4, 8*4, 16*4, 32*4, 64*4, 128*4, 256*4]
    results = {file: [] for file in input_files}

    for input_file in input_files:
        for size in block_sizes:
            miss_rate = run_dinero(8, size, 2, input_file)  
            results[input_file].append((size, miss_rate))

    return results, block_sizes

def analyze_associativity(input_files):
    associativities = [1, 2, 4, 8, 16, 32, 64, 128, 256]
    results = {file: [] for file in input_files}

    for input_file in input_files:
        for assoc in associativities:
            miss_rate = run_dinero(8, 16, assoc, input_file) 
            results[input_file].append((assoc, miss_rate))

    return results, associativities

def plot_results(results, x_values, x_label, y_label, title, filename):
    plt.figure(figsize=(10, 6))
    for input_file, data in results.items():
        miss_rates = [d[1] for d in data]
        plt.plot(x_values, miss_rates, marker='o', label=input_file)

    plt.xscale('log', base=2)
    plt.xlabel(x_label)
    plt.ylabel(y_label)
    plt.title(title)
    plt.legend()
    plt.grid(True)
    #plt.show()
    plt.savefig(filename)
    plt.close()

input_files = ['c1.din', 'spice.din', 'tex.din']

cache_results, cache_sizes = analyze_cache_sizes(input_files)
plot_results(cache_results, cache_sizes, 'Cache Size (KB)', 'Demand Miss Rate', 'Cache Size vs Demand Miss Rate', 'cache-size-plot.png')

block_results, block_sizes = analyze_block_sizes(input_files)
plot_results(block_results, block_sizes, 'Block Size (bytes)', 'Demand Miss Rate', 'Block Size vs Demand Miss Rate', 'block-size-plot.png')

assoc_results, associativities = analyze_associativity(input_files)
plot_results(assoc_results, associativities, 'Associativity', 'Demand Miss Rate', 'Associativity vs Demand Miss Rate', 'assoc-plot.png')
