import csv


def update_upn_suffix(input_file, output_file, new_suffix="@JCA99.onmicrosoft.com"):
    with (
        open(input_file, mode="r", newline="", encoding="utf-8") as infile,
        open(output_file, mode="w", newline="", encoding="utf-8") as outfile,
    ):
        reader = csv.reader(infile)
        writer = csv.writer(outfile)

        # Read and write header
        header = next(reader)
        writer.writerow(header)

        for row in reader:
            user_principal_name = row[0]
            proxy_address = row[1]

            # Extract username before '@' and append new suffix
            username = user_principal_name.split("@")[0]
            new_upn = f"{username}{new_suffix}"

            writer.writerow([new_upn, proxy_address])


# Example usage
input_csv = "onlyjca.csv"  # Replace with actual input file
output_csv = "final.csv"  # Replace with desired output file
update_upn_suffix(input_csv, output_csv)
