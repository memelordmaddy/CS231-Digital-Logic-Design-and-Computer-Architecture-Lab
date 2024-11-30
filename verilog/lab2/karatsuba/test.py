# Python script to compare expected output with given ouput
# To check the validity run the following commands in order
# iverilog karatsuba.v tb_karatsuba.v
# ./a.out > output.txt
# python3 test.py
import re

def check_discrepancies(filename):
    count=0
    with open(filename, 'r') as file:
        lines = file.readlines()

    # Regular expression to extract values from the lines
    pattern = re.compile(r"X =\s*(\d+)\s*, Y =\s*(\d+)\s*, Z =\s*(\d+)\s*\(Expected:\s*(\d+)\)")

    all_passed = True  # Flag to track if all test cases pass

    for line in lines:
        match = pattern.search(line)
        if match:
            x = int(match.group(1))
            y = int(match.group(2))
            z = int(match.group(3))
            expected = int(match.group(4))

            if z != expected:
                all_passed = False
                print(f"X = {x}, Y = {y}, Z = {z} (Expected: {expected})")
                count +=1
                print(count)

    if all_passed:
        print("All test cases passed.")


# Call the function with the path to the output file
check_discrepancies('output.txt')
