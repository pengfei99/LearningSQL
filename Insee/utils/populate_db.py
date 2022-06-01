import jinja2


def populate_template(file_path: str, context: dict) -> str:
    path, file_name = os.path.split(file_path)
    return (
        jinja2.Environment(loader=jinja2.FileSystemLoader(path or "./"))
            .get_template(file_name)
            .render(context)
    )


def main():
    # step1: Generate the k8s job files
    pass
    # step2: submit the k8s job


if __name__ == "__main__":
    main()
