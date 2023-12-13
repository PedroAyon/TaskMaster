from datetime import datetime


def to_date(dateString):
    if not dateString:
        return None
    return datetime.strptime(dateString, "%Y-%m-%d").date()


def from_date(date):
    if not date:
        return None
    return date.strftime('%Y-%m-%d')
