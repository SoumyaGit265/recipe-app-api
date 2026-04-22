"""
Django command to wait for the dtatabase to be available.
"""
from django.core.management.base import BaseCommand
from psycopg2 import OperationalError as Psycopg2Error
from django.db.utils import OperationalError


class Command(BaseCommand):
    """Django command to wait for the database."""

    def handle(self, *args, **options):
        """Entrypoint for command"""
        self.stdout.write("Waiting for database...")
        db_up = False
        while not db_up:
            try:
                self.check(databases=['default'])
                '''
                This check function automatically checks if the
                database which is marked as 'default' is up or not up.
                '''
                db_up = True
            except (Psycopg2Error, OperationalError):
                self.stdout.write('Database unavailable, waiting 1 second...')

        self.stdout.write(self.style.SUCCESS('Database Available!'))
