import csv


def split_proxy_addresses(input_file, output_file):
    with (
        open(input_file, mode="r", newline="", encoding="utf-8") as infile,
        open(output_file, mode="w", newline="", encoding="utf-8") as outfile,
    ):
        reader = csv.reader(infile)
        writer = csv.writer(outfile)

        # Write header if needed
        header = next(reader)
        writer.writerow(header)

        for row in reader:
            user_principal_name = row[0]
            proxy_addresses = row[1].split("+")  # Split by '+'

            for proxy in proxy_addresses:
                proxy = proxy.strip()
                if "jcaelectronics.ca" in proxy or "jcatechnologies.com" in proxy:
                    writer.writerow([user_principal_name, proxy])


# Example usage
input_csv = "usersUPNProxy.csv"  # Replace with actual input file
output_csv = "onlyjca.csv"  # Replace with desired output file
split_proxy_addresses(input_csv, output_csv)
