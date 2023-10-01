async function configure(config = []) {
  const printerIp = config.find((c) => c.key === "printer_ip").value;
  const apiKey = config.find((c) => c.key === "api_key").value;

  const prusaLink = new PrusaLink(printerIp, apiKey);
  await prusaLink.init();

  return [
    { key: "printer_status", value: prusaLink.printer.getStatus },
    { key: "job_name", value: prusaLink.job.getName },
    { key: "progress", value: prusaLink.job.getProgress },
    { key: "elapsed", value: prusaLink.job.getElapsed },
    { key: "remaining", value: prusaLink.job.getRemaining },
  ];
}

class PrusaLink {
  constructor(ip, apiKey) {
    this.ip = ip;
    this.apiKey = apiKey;
  }

  async init() {
    await this.initPrinter();
    await this.initJob();
  }

  async refresh() {
    this.init();
  }

  async initPrinter() {
    try {
      const p = await this.request("printer");
      this.printer = new Printer(p);
    } catch (e) {
      this.printer = new Printer({ state: { text: "Offline" } });
    }
  }

  async initJob() {
    try {
      const j = await this.request("job");
      this.job = new Job(j);
    } catch (e) {
      this.job = new Job({ state: "Offline" });
    }
  }

  async request(type = "printer") {
    const resp = await fetch(`http://${this.ip}/api/${type}`, {
      method: "GET",
      headers: {
        "Content-Type": "application/json",
        "X-Api-Key": this.apiKey,
      },
      signal: AbortSignal.timeout(3000),
    });

    return await resp.json();
  }
}

class Printer {
  constructor({ state, telemetry, temperature }) {
    this.state = state;
    this.telemetry = telemetry;
    this.temperature = temperature;
  }

  get getStatus() {
    return this.state.text;
  }
}

class Job {
  constructor({ job, progress, state }) {
    this.details = job;
    this.progress = progress;
    this.state = state;
  }

  get isPrinting() {
    return this.state === "Printing";
  }

  get getName() {
    if (!this.isPrinting) {
      return "No job";
    }
    return this.details.file.name;
  }

  get getElapsed() {
    if (!this.isPrinting) {
      return "";
    }
    return this.humanizeTime(this.progress.printTime);
  }

  get getRemaining() {
    if (!this.isPrinting) {
      return "";
    }
    return this.humanizeTime(this.progress.printTimeLeft);
  }

  get getProgress() {
    return (this.progress?.completion || 0.0).toString();
  }

  humanizeTime(seconds) {
    return new Date(1000 * seconds).toISOString().slice(11, 19);
  }
}

module.exports = configure;
