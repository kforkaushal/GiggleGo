import wave
import struct
import math
import os

SAMPLE_RATE = 44100

def write_wav(filename, samples):
    os.makedirs(os.path.dirname(filename), exist_ok=True)
    with wave.open(filename, 'w') as wav_file:
        wav_file.setnchannels(1)  # Mono
        wav_file.setsampwidth(2)  # 16-bit
        wav_file.setframerate(SAMPLE_RATE)
        # Normalize and clip
        max_val = max(abs(s) for s in samples) or 1.0
        scale = 30000.0 / max_val
        frames = bytearray()
        for s in samples:
            val = int(s * scale)
            val = max(-32767, min(32767, val))
            frames.extend(struct.pack('<h', val))
        wav_file.writeframes(frames)
    print(f"Generated: {filename} ({len(samples)} samples, {len(samples)/SAMPLE_RATE:.2f}s)")

def generate_correct():
    duration = 0.75
    total_samples = int(SAMPLE_RATE * duration)
    samples = [0.0] * total_samples
    notes = [
        (523.25, 0.00),  # C5
        (659.25, 0.10),  # E5
        (783.99, 0.20),  # G5
        (1046.50, 0.30), # C6
    ]
    for freq, start_t in notes:
        start_idx = int(start_t * SAMPLE_RATE)
        for i in range(start_idx, total_samples):
            t = (i - start_idx) / SAMPLE_RATE
            env = math.exp(-6.5 * t)
            # Marimba / glockenspiel chime timbre: fundamental + harmonics
            s = (0.7 * math.sin(2 * math.pi * freq * t) +
                 0.25 * math.sin(2 * math.pi * freq * 2 * t) +
                 0.1 * math.sin(2 * math.pi * freq * 3 * t)) * env
            samples[i] += s
    return samples

def generate_wrong():
    # Gentle cartoon wobble / boing
    duration = 0.40
    total_samples = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(total_samples):
        t = i / SAMPLE_RATE
        env = math.sin(math.pi * min(1.0, t / 0.03)) * math.exp(-4.5 * t)
        # Pitch starts at 330 Hz and bends down to 220 Hz with slight vibrato
        f = 330.0 - (110.0 * (t / duration)) + 12.0 * math.sin(2 * math.pi * 14.0 * t)
        s = math.sin(2 * math.pi * f * t) * env
        samples.append(s)
    return samples

def generate_complete():
    # Fanfare chord jingle
    duration = 1.35
    total_samples = int(SAMPLE_RATE * duration)
    samples = [0.0] * total_samples
    notes = [
        (523.25, 0.00, 4.0),   # C5
        (659.25, 0.12, 4.0),   # E5
        (783.99, 0.24, 4.0),   # G5
        (1046.50, 0.36, 2.5),  # C6 sustained
        (1318.51, 0.44, 2.5),  # E6 sustained
    ]
    for freq, start_t, decay in notes:
        start_idx = int(start_t * SAMPLE_RATE)
        for i in range(start_idx, total_samples):
            t = (i - start_idx) / SAMPLE_RATE
            env = math.exp(-decay * t)
            # Bell timbre with subtle chorus
            s = (0.65 * math.sin(2 * math.pi * freq * t) +
                 0.25 * math.sin(2 * math.pi * freq * 2 * t) +
                 0.10 * math.sin(2 * math.pi * (freq * 1.003) * t)) * env
            samples[i] += s
    return samples

def generate_pop():
    # Bubble pop
    duration = 0.08
    total_samples = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(total_samples):
        t = i / SAMPLE_RATE
        # Fast upward chirp 400Hz -> 1200Hz then quick decay
        f = 400.0 + 800.0 * (t / duration)
        env = math.exp(-35.0 * t)
        s = math.sin(2 * math.pi * f * t) * env
        samples.append(s)
    return samples

if __name__ == '__main__':
    out_dir = os.path.join(os.path.dirname(__file__), '..', 'assets', 'sounds')
    write_wav(os.path.join(out_dir, 'correct.wav'), generate_correct())
    write_wav(os.path.join(out_dir, 'wrong.wav'), generate_wrong())
    write_wav(os.path.join(out_dir, 'complete.wav'), generate_complete())
    write_wav(os.path.join(out_dir, 'pop.wav'), generate_pop())
    print("All audio files generated successfully!")
