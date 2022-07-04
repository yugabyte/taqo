import dataclasses


class Singleton(type):
    _instances = {}

    def __call__(cls, *args, **kwargs):
        # sourcery skip: instance-method-first-arg-name
        if cls not in cls._instances:
            cls._instances[cls] = super(Singleton, cls).__call__(*args, **kwargs)
        return cls._instances[cls]


@dataclasses.dataclass
class Config(metaclass=Singleton):
    host: str = None
    port: str = None
    username: str = None
    password: str = None
    database: str = None

    enable_statistics: bool = False
    explain_analyze: bool = False

    test: str = None
    model: str = None

    skip_table_scan_hints: bool = None
    skip_model_creation: bool = None
    num_queries: int = None
    num_retries: int = None
    skip_timeout_delta: int = None
    max_optimizations: int = None

    asciidoctor_path: str = None
    verbose: bool = False
