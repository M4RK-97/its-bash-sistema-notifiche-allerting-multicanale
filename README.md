# 🚨 Sistema Alerting Multi-Canale (Bash + PHP + Docker)

Sistema di monitoraggio e notifiche multi-canale (email, Slack, Telegram) progettato per essere:
- minimale
- modulare
- facilmente deployabile
- scalabile in evoluzione

---

## 🧠 Architettura

### Componenti

- **Bash (core engine)**
  - Monitoraggio servizi, disco, CPU
  - Rate limiting
  - Invio notifiche
  - Scrittura stato runtime

- **PHP (view layer)**
  - Rendering dashboard dinamico
  - Nessuna logica di business

- **Apache**
  - Serve dashboard su porta 80

- **Docker**
  - Ambiente unico replicabile

---

## 📦 Struttura progetto

```txt
.
├── docker-compose.yml
├── Dockerfile
├── opt/
│   └── alerting/
│       ├── alert-system.sh
│       ├── send-notification.sh
│       ├── variables.data
│       └── templates/
│           ├── service_down.tpl
│           ├── disk_high.tpl
│           └── cpu_high.tpl
├── etc/
│   └── alerting/
│       └── config.conf
└── var/
    └── www/
        └── html/
            └── dashboard.php
```

---

## ⚙️ Variabile centrale

### `variables.data`

Single Source of Truth runtime.

Formato:

```txt
KEY=VALUE
```


Esempio:


```txt
HOST=ops-node-01
TIMESTAMP=2026-04-09 14:22:00
OVERALL_STATUS=CRITICAL
DISK_USAGE=91
LOAD_AVG=2.80
SERVICES_STATUS=nginx:DOWN,ssh:ACTIVE
```


---

## 🚀 Avvio rapido

### 1. Build

```bash
docker compose build
```

### 2. Run

```bash
docker compose up -d 
```

### 🌐 Accesso dashboard

```
http://localhost:8080/dashboard.php
```

### 🔁 Loop monitoraggio

Il sistema esegue `alert-system.sh` ogni 60 secondi, gestito via entrypoint nel container.

---

## 📡 Notifiche

Configurabili in `/etc/alerting/config.conf`

Canali supportati:
- Email (mail)
- Slack (webhook)
- Telegram (bot API)
- Modalità simulata

Se il config contiene valori placeholder:
- Slack → simulato
- Telegram → simulato

---

## 🧱 Rate Limiting

- 1 alert per tipo ogni 15 minuti
- Lock files: `/tmp/alerting-rate-limit/`

---

## 🧪 Test rapidi

**Simulare disco pieno:**
```bash
DISK_USAGE_THRESHOLD=1
```

**Simulare CPU alta:**
```bash
LOAD_AVERAGE_THRESHOLD=0.01
```

---

## 📜 Log

**Percorso:** `/var/log/alerts.log`

**Formato:**
```
timestamp | channel | status | type | severity
```










docker exec -it alerting_system /bin/bash
docker compose restart